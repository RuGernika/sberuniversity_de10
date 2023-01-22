/*=========================*/
/* RailwayTransportations  */
/*    Tkachenko Daria DE10 */
/*=========================*/


create table "de10.Railway_Transportations" (
			"id_railway_transportation" integer not null,
			"data_arrival" date,
			"data_distance" date,
			"station_distinct" integer,
			"highway" integer,
			"station_arrival" integer not null,
	constraint "Railway_Transportations_pk" primary key("id_railway_transportation")
);


create table "de10.Routs" (
		"id_distinct" integer not null,
		"id_arrival" integer not null,
		"distance" integer
);


create table "de10.Trains" (
	"id_freight_car" integer not null,
	"id_locomotive" integer not null,
	"id_railway_transportation" integer not null
);


create table "de10.Locomotives" (
		"number_locomotiv" integer not null,
		"type_locomotiv" integer not null,
	constraint "Locomotives_pk" primary key("number_locomotiv")
);


create table "de10.Types_Locomotiv" (
	"id_type_locomotiv" integer not null,
	"id_type_locomotiv" integer not null,
	"abbreviated_ name" varchar(255),
	"name_ locomotiv" varchar(255),
	"load capacity" float,
	"speed" float
 unique (abbreviated_ name, name_ locomotiv)
);


create table "de10.Freight Cars" (
		"id_freight_car" integer not null,
		"id_type_freight_car" integer not null,
	constraint "Freight Cars_pk" primary key("id_freight_car")
);

create table "de10.Types_Freight_Car" (
		"id_type_freight_car" integer not null,
		"name" varchar(255),
		"value_freight_car" float,
		"capacity_freight_car" float,
	constraint "Types_Freight_Car_pk" primary key("id_type_freight_car")
);


create table "de10.Stations" (
		"ECR" integer not null,
		"highway" integer,
		"name_station" varchar(255) unique,
	constraint "Stations_pk" primary key("ECR")
);




/* ADD  FOREIGN KEY  */

ALTER TABLE "Railway_Transportations" ADD constraint "Railway_Transportations_fk0" FOREIGN KEY ("station_distinct") REFERENCES "Stations"("ECR");
ALTER TABLE "Railway_Transportations" ADD constraint "Railway_Transportations_fk1" FOREIGN KEY ("station_arrival") REFERENCES "Stations"("ECR");
ALTER TABLE "Locomotives" ADD constraint "Locomotives_fk0" FOREIGN KEY ("type_locomotiv") REFERENCES "Types_Locomotiv"("id_type_locomotiv");
ALTER TABLE "Freight Cars" ADD constraint "Freight Cars_fk0" FOREIGN KEY ("id_type_freight_car") REFERENCES "Types_Freight_Car"("id_type_freight_car");
ALTER TABLE "Routs" ADD constraint "Routs_fk0" FOREIGN KEY ("id_distinct") REFERENCES "Stations"("ECR");
ALTER TABLE "Routs" ADD constraint "Routs_fk1" FOREIGN KEY ("id_arrival") REFERENCES "Stations"("ECR");
ALTER TABLE "Trains" ADD constraint "Trains_fk0" FOREIGN KEY ("id_freight_car") REFERENCES "Freight Cars"("id_freight_car");
ALTER TABLE "Trains" ADD constraint "Trains_fk1" FOREIGN KEY ("id_locomotive") REFERENCES "Locomotives"("number_locomotiv");
ALTER TABLE "Trains" ADD constraint "Trains_fk2" FOREIGN KEY ("id_railway_transportation") REFERENCES "Railway_Transportations"("id_railway_transportation");

/* INCERT DATA */

/* Test DB */






