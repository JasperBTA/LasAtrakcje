-- Włączenie rozszerzenia dla generowania UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela: Users (Operatorzy)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: Attractions (Atrakcje)
CREATE TABLE attractions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    radius DOUBLE PRECISION NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: Measurements (Pomiary)
CREATE TABLE measurements (
    id UUID PRIMARY KEY, -- Idempotency key wysyłany z frontendu
    operator_id UUID NOT NULL REFERENCES users(id),
    attraction_id UUID NOT NULL REFERENCES attractions(id),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    stop_time TIMESTAMP WITH TIME ZONE,
    total_duration_seconds INTEGER,
    sync_status VARCHAR(50) NOT NULL DEFAULT 'SYNCED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexy dla optymalizacji
CREATE INDEX idx_measurements_operator_id ON measurements(operator_id);
CREATE INDEX idx_measurements_attraction_id ON measurements(attraction_id);
