CREATE TABLE IF NOT EXISTS tradier_symbols (symbol text, fetched_at timestamp);
CREATE UNIQUE INDEX IF NOT EXISTS tradier_symbols_symbol_idx ON tradier_symbols (symbol);

CREATE TABLE IF NOT EXISTS tradier_quotes (trade_date bigint, symbol text, data jsonb);
CREATE UNIQUE INDEX IF NOT EXISTS tradier_quotes_trade_date_symbol_idx ON tradier_quotes (trade_date, symbol);

CREATE TABLE IF NOT EXISTS tradier_positions (symbol text, cost_basis numeric);
