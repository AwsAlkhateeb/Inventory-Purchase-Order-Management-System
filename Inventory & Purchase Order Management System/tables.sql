create table ITEMS(
    item_id number primary key,
    item_name varchar2(50) not null,
    category varchar2(50),
    min_qty number default 0 check(min_qty>=0),
    current_qty number default 0 check(current_qty>=0),
    unit_price number(10,2) check(unit_price>=0)
);

create table SUPPLIERS(
    supplier_id number primary key,
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
    line_id number primary key,
    po_id number not null,
    item_id number not null,
    qty_requested number not null check (qty_requested>0),
    unit_price number(10,2) check (unit_price>=0),
    CONSTRAINT PO_LINES_po_id foreign key(po_id) references PURCHASE_ORDERS(po_id) on delete cascade,
    CONSTRAINT PO_LINES_item_id foreign key(item_id) references ITEMS(item_id),
    CONSTRAINT uq_po_item UNIQUE (po_id, item_id)
);

create table STOCK_MOVEMENTS(
    move_id number primary key,
    item_id number not null,
    qty number not null check (qty>0),
    move_type varchar2(10) not null check (move_type IN('IN','OUT')),
    move_date date default sysdate,
    CONSTRAINT STOCK_MOVEMENTS_item_id foreign key(item_id) references ITEMS(item_id)
);

