-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('rider', 'operator_admin', 'platform_admin');
CREATE TYPE "HoldStatus" AS ENUM ('held', 'confirmed', 'expired', 'cancelled');
CREATE TYPE "BookingStatus" AS ENUM ('pending', 'paid', 'cancelled');
CREATE TYPE "PaymentStatus" AS ENUM ('pending', 'succeeded', 'failed', 'refunded');
CREATE TYPE "TicketScanStatus" AS ENUM ('valid', 'used', 'void');

-- CreateTable
CREATE TABLE "users" (
  "id" TEXT NOT NULL,
  "email" TEXT NOT NULL,
  "phone" TEXT,
  "password_hash" TEXT NOT NULL,
  "role" "UserRole" NOT NULL DEFAULT 'rider',
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "operators" (
  "id" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "contact" TEXT,
  "status" TEXT NOT NULL DEFAULT 'active',
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "operators_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "buses" (
  "id" TEXT NOT NULL,
  "operator_id" TEXT NOT NULL,
  "seat_map_json" JSONB NOT NULL,
  "amenities" JSONB,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "buses_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "routes" (
  "id" TEXT NOT NULL,
  "origin" TEXT NOT NULL,
  "destination" TEXT NOT NULL,
  "distance_km" INTEGER NOT NULL,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "routes_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "trips" (
  "id" TEXT NOT NULL,
  "route_id" TEXT NOT NULL,
  "bus_id" TEXT NOT NULL,
  "departure_at" TIMESTAMP(3) NOT NULL,
  "base_fare" DECIMAL(10,2) NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'scheduled',
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "trips_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "seat_holds" (
  "id" TEXT NOT NULL,
  "trip_id" TEXT NOT NULL,
  "seat_number" TEXT NOT NULL,
  "status" "HoldStatus" NOT NULL DEFAULT 'held',
  "user_id" TEXT NOT NULL,
  "expires_at" TIMESTAMP(3) NOT NULL,
  "price_locked" DECIMAL(10,2) NOT NULL,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "seat_holds_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "bookings" (
  "id" TEXT NOT NULL,
  "user_id" TEXT NOT NULL,
  "trip_id" TEXT NOT NULL,
  "total_amount" DECIMAL(10,2) NOT NULL,
  "payment_status" "BookingStatus" NOT NULL DEFAULT 'pending',
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "bookings_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "tickets" (
  "id" TEXT NOT NULL,
  "booking_id" TEXT NOT NULL,
  "seat_number" TEXT NOT NULL,
  "qr_signature" TEXT NOT NULL,
  "scan_status" "TicketScanStatus" NOT NULL DEFAULT 'valid',
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "tickets_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "payments" (
  "id" TEXT NOT NULL,
  "booking_id" TEXT NOT NULL,
  "gateway_ref" TEXT,
  "amount" DECIMAL(10,2) NOT NULL,
  "status" "PaymentStatus" NOT NULL DEFAULT 'pending',
  "idempotency_key" TEXT NOT NULL,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- Indexes
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");
CREATE UNIQUE INDEX "payments_idempotency_key_key" ON "payments"("idempotency_key");
CREATE INDEX "seat_holds_trip_seat_active_idx" ON "seat_holds"("trip_id", "seat_number") WHERE "status" IN ('held', 'confirmed');
CREATE INDEX "seat_holds_trip_idx" ON "seat_holds"("trip_id");
CREATE INDEX "bookings_user_idx" ON "bookings"("user_id");
CREATE INDEX "tickets_booking_idx" ON "tickets"("booking_id");
CREATE INDEX "payments_booking_idx" ON "payments"("booking_id");

-- Foreign keys
ALTER TABLE "buses" ADD CONSTRAINT "buses_operator_id_fkey" FOREIGN KEY ("operator_id") REFERENCES "operators"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "trips" ADD CONSTRAINT "trips_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "routes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "trips" ADD CONSTRAINT "trips_bus_id_fkey" FOREIGN KEY ("bus_id") REFERENCES "buses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "seat_holds" ADD CONSTRAINT "seat_holds_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "seat_holds" ADD CONSTRAINT "seat_holds_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "payments" ADD CONSTRAINT "payments_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
