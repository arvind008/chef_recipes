create table if not exists vets (
  id int(4) unsigned not null auto_increment primary key,
  first_name varchar(30),
  last_name varchar(30),
  index(last_name)
) engine=innodb;

create table if not exists specialties (
  id int(4) unsigned not null auto_increment primary key,
  name varchar(80),
  index(name)
) engine=innodb;

create table if not exists vet_specialties (
  vet_id int(4) unsigned not null,
  specialty_id int(4) unsigned not null,
  foreign key (vet_id) references vets(id),
  foreign key (specialty_id) references specialties(id),
  unique (vet_id,specialty_id)
) engine=innodb;

create table if not exists types (
  id int(4) unsigned not null auto_increment primary key,
  name varchar(80),
  index(name)
) engine=innodb;

create table if not exists owners (
  id int(4) unsigned not null auto_increment primary key,
  first_name varchar(30),
  last_name varchar(30),
  address varchar(255),
  city varchar(80),
  telephone varchar(20),
  index(last_name)
) engine=innodb;

create table if not exists pets (
  id int(4) unsigned not null auto_increment primary key,
  name varchar(30),
  birth_date date,
  type_id int(4) unsigned not null,
  owner_id int(4) unsigned not null,
  index(name),
  foreign key (owner_id) references owners(id),
  foreign key (type_id) references types(id)
) engine=innodb;

create table if not exists visits (
  id int(4) unsigned not null auto_increment primary key,
  pet_id int(4) unsigned not null,
  visit_date date,
  description varchar(255),
  foreign key (pet_id) references pets(id)
) engine=innodb;

