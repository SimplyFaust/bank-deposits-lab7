CREATE SCHEMA IF NOT EXISTS bank;
SET search_path TO bank, public;

CREATE TABLE bank.client (
    client_id         SERIAL PRIMARY KEY,
    first_name        VARCHAR(50)   NOT NULL,
    last_name         VARCHAR(50)   NOT NULL,
    passport_number   VARCHAR(20)   UNIQUE NOT NULL,
    birth_date        DATE          NOT NULL CHECK (birth_date < CURRENT_DATE - INTERVAL '18 years'),
    address           TEXT,
    phone             VARCHAR(20),
    email             VARCHAR(100),
    registration_date DATE          NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE bank.currency (
    currency_id       SERIAL PRIMARY KEY,
    name              VARCHAR(50)  NOT NULL UNIQUE
);

CREATE TABLE bank.branch (
    branch_id         SERIAL PRIMARY KEY,
    name              VARCHAR(100) NOT NULL,
    address           TEXT         NOT NULL,
    phone             VARCHAR(20)
);

CREATE TABLE bank.deposit_type (
    deposit_type_id   SERIAL PRIMARY KEY,
    name              VARCHAR(100) NOT NULL,
    min_amount        NUMERIC(15,2) NOT NULL CHECK (min_amount >= 0),
    min_term_months   INTEGER      NOT NULL CHECK (min_term_months > 0),
    base_interest_rate NUMERIC(5,4) NOT NULL CHECK (base_interest_rate BETWEEN 0 AND 1)
);

CREATE TABLE bank.deposit (
    deposit_id        SERIAL PRIMARY KEY,
    client_id         INTEGER NOT NULL REFERENCES bank.client(client_id) ON DELETE RESTRICT,
    deposit_type_id   INTEGER NOT NULL REFERENCES bank.deposit_type(deposit_type_id),
    currency_id       INTEGER NOT NULL REFERENCES bank.currency(currency_id),
    branch_id         INTEGER NOT NULL REFERENCES bank.branch(branch_id),
    start_date        DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date          DATE,
    initial_amount    NUMERIC(15,2) NOT NULL CHECK (initial_amount > 0),
    balance           NUMERIC(15,2) NOT NULL CHECK (balance >= 0),
    interest_rate     NUMERIC(5,4)  NOT NULL CHECK (interest_rate BETWEEN 0 AND 1),
    interest_periodicity VARCHAR(20) DEFAULT 'monthly',
    CONSTRAINT valid_end_date CHECK (end_date IS NULL OR end_date > start_date)
);

CREATE TABLE bank."transaction" (
    transaction_id    SERIAL PRIMARY KEY,
    deposit_id        INTEGER NOT NULL REFERENCES bank.deposit(deposit_id) ON DELETE CASCADE,
    transaction_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    transaction_type  VARCHAR(20) NOT NULL CHECK (transaction_type IN ('deposit', 'withdrawal', 'interest')),
    amount            NUMERIC(15,2) NOT NULL
);

CREATE INDEX idx_deposit_client      ON bank.deposit(client_id);
CREATE INDEX idx_deposit_branch      ON bank.deposit(branch_id);
CREATE INDEX idx_transaction_deposit ON bank."transaction"(deposit_id);
CREATE INDEX idx_transaction_date    ON bank."transaction"(transaction_date DESC);