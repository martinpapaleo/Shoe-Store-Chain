DO $$
DECLARE
  v_qty  INT;
  v_sell INT := 5;   -- units to sell
BEGIN
  SELECT qty INTO v_qty
  FROM sandbox.stock_demo
  WHERE product = 'Runner X';

  IF v_sell > v_qty THEN
    RAISE EXCEPTION 'Cannot sell % units of Runner X: only % in stock', v_sell, v_qty;
  END IF;

  UPDATE sandbox.stock_demo
  SET qty = qty - v_sell
  WHERE product = 'Runner X';

  IF v_qty - v_sell < 2 THEN
    RAISE WARNING 'Runner X is running low: % left', v_qty - v_sell;
  END IF;
END $$;
UPDATE sandbox.stock_demo SET qty = 10 WHERE product = 'Runner X';
SELECT * FROM sandbox.stock_demo;