create table ITEMS(
    item_id number GENERATED ALWAYS AS IDENTITY primary key,
    item_name varchar2(50) not null,
    category varchar2(50),
    min_qty number default 0 check(min_qty>=0),
    current_qty number default 0 check(current_qty>=0),
    unit_price number(10,2) check(unit_price>=0)
);

create table SUPPLIERS(
    supplier_id number GENERATED ALWAYS AS IDENTITY primary key,
    name varchar2(50) not null,
    phone varchar2(10) unique,
    email varchar2(200) unique
);

create table PURCHASE_ORDERS(
    po_id number primary key,
    supplier_id number not null,
    po date default sysdate,
    status varchar2(20) not null,
    CONSTRAINT PURCHASE_ORDERS_supplier_id foreign key(supplier_id) references SUPPLIERS(supplier_id),
    CONSTRAINT chk_po_status CHECK (status IN ('NEW','APPROVED','RECEIVED','CANCELLED'))
);

create table PO_LINES(
    line_id number GENERATED ALWAYS AS IDENTITY primary key,
    po_id number not null,
    item_id number not null,
    qty_requested number not null check (qty_requested>0),
    unit_price number(10,2) check (unit_price>=0),
    CONSTRAINT PO_LINES_po_id foreign key(po_id) references PURCHASE_ORDERS(po_id) on delete cascade,
    CONSTRAINT PO_LINES_item_id foreign key(item_id) references ITEMS(item_id),
    CONSTRAINT uq_po_item UNIQUE (item_id)
);

create table STOCK_MOVEMENTS(
    move_id number GENERATED ALWAYS AS IDENTITY primary key,
    item_id number not null,
    qty number not null check (qty>0),
    move_type varchar2(10) not null check (move_type IN('IN','OUT')),
    move_date date default sysdate,
    CONSTRAINT STOCK_MOVEMENTS_item_id foreign key(item_id) references ITEMS(item_id)
);

INSERT INTO items VALUES (1, 'Laptop', 'IT', 5, 10, 750);
INSERT INTO items VALUES (2, 'Mouse', 'IT', 20, 50, 15);
INSERT INTO items VALUES (3, 'Keyboard', 'IT', 15, 30, 25);
INSERT INTO items VALUES (4, 'Monitor', 'IT', 5, 12, 180);
INSERT INTO items VALUES (5, 'Printer', 'IT', 2, 4, 220);
INSERT INTO items VALUES (6, 'Router', 'Network', 3, 5, 120);
INSERT INTO items VALUES (7, 'Switch 24 Port', 'Network', 2, 3, 260);
INSERT INTO items VALUES (8, 'External Hard Disk 1TB', 'Storage', 4, 8, 95);
INSERT INTO items VALUES (9, 'USB Flash 64GB', 'Storage', 10, 40, 12);
INSERT INTO items VALUES (10, 'UPS', 'Power', 1, 2, 300);

INSERT INTO suppliers VALUES (1, 'Tech Supplier Co', '0791111111', 'tech@supplier.com');
INSERT INTO suppliers VALUES (2, 'IT Solutions Ltd', '0782222222', 'sales@itsolutions.com');
INSERT INTO suppliers VALUES (3, 'Network Gear Supplier', '0773333333', 'sales@netgear.com');
INSERT INTO suppliers VALUES (4, 'Office Tech Supplies', '0764444444', 'info@officetech.com');

INSERT INTO purchase_orders VALUES (1001, 1, SYSDATE, 'NEW');
INSERT INTO purchase_orders VALUES (1002, 3, SYSDATE, 'NEW');
INSERT INTO purchase_orders VALUES (1003, 4, SYSDATE, 'NEW');

INSERT INTO po_lines VALUES (1, 1001, 1, 5, 750);
INSERT INTO po_lines VALUES (2, 1001, 2, 20, 15);
INSERT INTO po_lines VALUES (3, 1002, 6, 3, 120);
INSERT INTO po_lines VALUES (4, 1002, 7, 2, 260);
INSERT INTO po_lines VALUES (5, 1003, 8, 4, 95);
INSERT INTO po_lines VALUES (6, 1003, 9, 20, 12);
INSERT INTO po_lines VALUES (7, 1003, 10, 1, 300);



