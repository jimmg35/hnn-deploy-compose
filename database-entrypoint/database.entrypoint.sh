#!/bin/bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE DATABASE $APP_DB_NAME;
  GRANT ALL PRIVILEGES ON DATABASE $APP_DB_NAME TO $APP_DB_USER;
  \connect $APP_DB_NAME $APP_DB_USER
  BEGIN;

    CREATE EXTENSION postgis;	

    CREATE TABLE temp_apr (
      id VARCHAR(255) UNIQUE,
      transactiontime TIMESTAMP,
      completiontime TIMESTAMP,
      transferFloor INTEGER,
      unitPrice INTEGER,
      priceWithoutParking INTEGER,
      roomNumber INTEGER,
      hallNumber INTEGER,
      bathNumber INTEGER,
      buildingTransferArea INTEGER,
      parkingSpacePrice INTEGER,
      parkingSpaceTransferArea INTEGER,
      price INTEGER,
      landAmount INTEGER,
      buildingAmount INTEGER,
      parkAmount INTEGER,
      buildingType INTEGER,
      floor INTEGER,
      urbanLandUse INTEGER,
      buildingArea INTEGER,
      subBuildingArea INTEGER,
      belconyArea INTEGER,
      landTransferArea INTEGER,
      parkingSpaceType INTEGER,
      longitude FLOAT,
      latitude FLOAT,
      "yhat-hnn" FLOAT,
      y_x FLOAT,
      "yhat-mlp" FLOAT,
      y_y FLOAT,
      address VARCHAR(255)
    );

    CREATE TABLE apr (
      id VARCHAR(255) UNIQUE,
      transactiontime TIMESTAMP,
      completiontime TIMESTAMP,
      transferFloor INTEGER,
      unitPrice INTEGER,
      priceWithoutParking INTEGER,
      roomNumber INTEGER,
      hallNumber INTEGER,
      bathNumber INTEGER,
      buildingTransferArea INTEGER,
      parkingSpacePrice INTEGER,
      parkingSpaceTransferArea INTEGER,
      price INTEGER,
      landAmount INTEGER,
      buildingAmount INTEGER,
      parkAmount INTEGER,
      buildingType INTEGER,
      floor INTEGER,
      urbanLandUse INTEGER,
      buildingArea INTEGER,
      subBuildingArea INTEGER,
      belconyArea INTEGER,
      landTransferArea INTEGER,
      parkingSpaceType INTEGER,
      coordinate geography(Point, 4326),
      "yhat-hnn" FLOAT,
      y_x FLOAT,
      "yhat-mlp" FLOAT,
      y_y FLOAT,
      address VARCHAR(255)
    );


    COPY temp_apr (id, transactiontime, completiontime, transferFloor, unitPrice, priceWithoutParking, roomNumber, hallNumber, bathNumber, buildingTransferArea, parkingSpacePrice, parkingSpaceTransferArea, price, landAmount, buildingAmount, parkAmount, buildingType, floor, urbanLandUse, buildingArea, subBuildingArea, belconyArea, landTransferArea, parkingSpaceType, longitude, latitude, "yhat-hnn", y_x, "yhat-mlp", y_y, address) FROM '/docker-entrypoint-initdb.d/data/data-utf8.csv' DELIMITER ',' CSV HEADER;

    INSERT INTO apr (id, transactiontime, completiontime, transferFloor, unitPrice, priceWithoutParking, roomNumber, hallNumber, bathNumber, buildingTransferArea, parkingSpacePrice, parkingSpaceTransferArea, price, landAmount, buildingAmount, parkAmount, buildingType, floor, urbanLandUse, buildingArea, subBuildingArea, belconyArea, landTransferArea, parkingSpaceType, coordinate, "yhat-hnn", y_x, "yhat-mlp", y_y, address) SELECT id, transactiontime, completiontime, transferFloor, unitPrice, priceWithoutParking, roomNumber, hallNumber, bathNumber, buildingTransferArea, parkingSpacePrice, parkingSpaceTransferArea, price, landAmount, buildingAmount, parkAmount, buildingType, floor, urbanLandUse, buildingArea, subBuildingArea, belconyArea, landTransferArea, parkingSpaceType, ST_SetSRID(ST_MakePoint(longitude, latitude), 4326), "yhat-hnn", y_x, "yhat-mlp", y_y, address FROM temp_apr;

  COMMIT;
EOSQL