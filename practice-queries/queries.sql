DO $$
DECLARE
  v_product VARCHAR := 'Runner X';
  v_qty     INT;
BEGIN
  SELECT qty INTO v_qty
  FROM sandbox.stock_demo
  WHERE product = v_product;

  RAISE NOTICE 'Product % has % units (100%% real data)', v_product, v_qty;
END $$;
