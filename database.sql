CREATE TABLE IF NOT EXISTS tradier_symbols (symbol text, fetched_at timestamp);
CREATE UNIQUE INDEX IF NOT EXISTS tradier_symbols_symbol_idx ON tradier_symbols (symbol);

CREATE TABLE IF NOT EXISTS tradier_quotes (symbol text, data jsonb, fetched_at timestamp);
CREATE UNIQUE INDEX IF NOT EXISTS tradier_quotes_symbol_fetched_at_idx ON tradier_quotes (symbol, fetched_at);
