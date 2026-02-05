CREATE OR REPLACE PACKAGE inventory_pkg AS

  -- إنشاء طلب شراء (Header)
  PROCEDURE create_purchase_order (
    p_po_id        IN NUMBER,
    p_supplier_id  IN NUMBER
  );

  -- إضافة صنف إلى طلب الشراء
  PROCEDURE add_po_line (
    p_line_id      IN NUMBER,
    p_po_id        IN NUMBER,
    p_item_id      IN NUMBER,
    p_qty          IN NUMBER,
    p_unit_price   IN NUMBER
  );

  -- اعتماد طلب الشراء
  PROCEDURE approve_purchase_order (
    p_po_id IN NUMBER
  );

  -- تسجيل حركة مخزون (IN / OUT)
  PROCEDURE record_stock_movement (
    p_move_id   IN NUMBER,
    p_item_id   IN NUMBER,
    p_qty       IN NUMBER,
    p_move_type IN VARCHAR2
  );

  -- استلام طلب الشراء
  PROCEDURE receive_purchase_order (
    p_po_id IN NUMBER
  );

END inventory_pkg;
/
CREATE OR REPLACE PACKAGE BODY inventory_pkg AS

  ----------------------------------------------------
  PROCEDURE create_purchase_order (
    p_po_id        IN NUMBER,
    p_supplier_id  IN NUMBER
  ) IS
  BEGIN
    INSERT INTO purchase_orders (
      po_id, supplier_id, po, status
    )
    VALUES (
      p_po_id, p_supplier_id, SYSDATE, 'NEW'
    );
  END create_purchase_order;

  ----------------------------------------------------
  PROCEDURE add_po_line (
    p_line_id      IN NUMBER,
    p_po_id        IN NUMBER,
    p_item_id      IN NUMBER,
    p_qty          IN NUMBER,
    p_unit_price   IN NUMBER
  ) IS
  BEGIN
    INSERT INTO po_lines (
      line_id, po_id, item_id, qty_requested, unit_price
    )
    VALUES (
      p_line_id, p_po_id, p_item_id, p_qty, p_unit_price
    );
  END add_po_line;

  ----------------------------------------------------
  PROCEDURE approve_purchase_order (
    p_po_id IN NUMBER
  ) IS
  BEGIN
    UPDATE purchase_orders
    SET status = 'APPROVED'
    WHERE po_id = p_po_id
      AND status = 'NEW';

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Purchase order cannot be approved');
    END IF;
  END approve_purchase_order;

  ----------------------------------------------------
  PROCEDURE record_stock_movement (
    p_move_id   IN NUMBER,
    p_item_id   IN NUMBER,
    p_qty       IN NUMBER,
    p_move_type IN VARCHAR2
  ) IS
    v_current_qty NUMBER;
  BEGIN
    SELECT current_qty
    INTO v_current_qty
    FROM items
    WHERE item_id = p_item_id
    FOR UPDATE;

    IF p_move_type = 'OUT' AND v_current_qty < p_qty THEN
      RAISE_APPLICATION_ERROR(-20002, 'Insufficient stock');
    END IF;

    INSERT INTO stock_movements (
      move_id, item_id, qty, move_type, move_date
    )
    VALUES (
      p_move_id, p_item_id, p_qty, p_move_type, SYSDATE
    );

    IF p_move_type = 'IN' THEN
      UPDATE items
      SET current_qty = current_qty + p_qty
      WHERE item_id = p_item_id;
    ELSE
      UPDATE items
      SET current_qty = current_qty - p_qty
      WHERE item_id = p_item_id;
    END IF;
  END record_stock_movement;

  ----------------------------------------------------
  PROCEDURE receive_purchase_order (
    p_po_id IN NUMBER
  ) IS
    CURSOR c_po_lines IS
      SELECT item_id, qty_requested
      FROM po_lines
      WHERE po_id = p_po_id;

    v_move_id NUMBER := 1;
    v_status  purchase_orders.status%TYPE;
  BEGIN
    SELECT status
    INTO v_status
    FROM purchase_orders
    WHERE po_id = p_po_id
    FOR UPDATE;

    IF v_status <> 'APPROVED' THEN
      RAISE_APPLICATION_ERROR(-20003, 'Purchase order not approved');
    END IF;

    FOR r IN c_po_lines LOOP
      record_stock_movement(
        p_move_id   => v_move_id,
        p_item_id   => r.item_id,
        p_qty       => r.qty_requested,
        p_move_type => 'IN'
      );
      v_move_id := v_move_id + 1;
    END LOOP;

    UPDATE purchase_orders
    SET status = 'RECEIVED'
    WHERE po_id = p_po_id;
  END receive_purchase_order;

END inventory_pkg;
/
