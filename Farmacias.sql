
# Fichero para la solución del Caso Práctico de "Bases de datos". 

# Modifíquelo para incluir el codigo necesario para llevar a cabo los pasos necesarios para
# resolver los distintos apartados. Debe incluir comentarios con explicaciones del código
# propuesto.


-- Si existe, borrar la base de datos CADENAFARMACIAS:

DROP DATABASE IF EXISTS CADENAFARMACIAS;

-- Crear la base de datos CADENAFARMACIAS:

CREATE DATABASE IF NOT EXISTS CADENAFARMACIAS;

-- Usar la base de datos CADENAFARMACIAS: 

USE CADENAFARMACIAS;


#################################################################################################
# 1. Cree la base de datos con las tablas que se extraen del diagrama E-R presentado y del propio 
#    enunciado del problema.
#################################################################################################
DROP TABLE IF EXISTS Farmacia;
CREATE TABLE Farmacia(
idFarm int UNSIGNED,
nombre varchar(30) NOT NULL,
direccion varchar(30) NOT NULL,
PRIMARY KEY  (idFarm)
);
DROP TABLE IF EXISTS Medicamento;
CREATE TABLE Medicamento(
idMed int UNSIGNED NOT NULL,
nombre varchar(30) NOT NULL,
precio int UNSIGNED NOT NULL,
descripcion varchar(60) NOT NULL,
PRIMARY KEY  (idMed)
);
DROP TABLE IF EXISTS Inventario;
CREATE TABLE Inventario(
idInv int UNSIGNED,
farmId int UNSIGNED,
medId int UNSIGNED,
stock int UNSIGNED NOT NULL,
PRIMARY KEY (idInv),
FOREIGN KEY (farmId) REFERENCES Farmacia(idFarm),
FOREIGN KEY (medId) REFERENCES Medicamento(idMed)
);
DROP TABLE IF EXISTS Cliente;
CREATE TABLE Cliente(
idCliente int UNSIGNED,	
nombre varchar(30),
PRIMARY KEY (idCliente)
);
DROP TABLE IF EXISTS Compra;
CREATE TABLE Compra(
idCompra int UNSIGNED,
clienteId int UNSIGNED,
medicamentoId int UNSIGNED,
fecha date,
precio int UNSIGNED,
PRIMARY KEY (idCompra),
FOREIGN KEY (clienteId) REFERENCES Cliente(idCliente),
FOREIGN KEY (medicamentoId) REFERENCES Medicamento(idMed)
);
DROP TABLE IF EXISTS Pedido;
CREATE TABLE Pedido(
idPedido int UNSIGNED,
fecha date,
farmaciaId int UNSIGNED,
PRIMARY KEY (idPedido),
FOREIGN KEY (farmaciaId) REFERENCES Farmacia(idFarm)
);
DROP TABLE IF EXISTS Pedido_Medicamento;
CREATE TABLE Pedido_Medicamento(
idPedidoMed int UNSIGNED,
medId int UNSIGNED,
pedId int UNSIGNED,
PRIMARY KEY (idPedidoMed),
FOREIGN KEY (medId) REFERENCES Medicamento(idMed),
FOREIGN KEY (pedId) REFERENCES Pedido(idPedido)
);

DROP TABLE IF EXISTS Detalle_Pedido;
CREATE TABLE Detalle_Pedido(
pedId int UNSIGNED,
cantidad int UNSIGNED,
precio int UNSIGNED,
ID_medicamento int UNSIGNED,
PRIMARY KEY (pedId,ID_medicamento),
FOREIGN KEY (pedId) REFERENCES Pedido(idPedido),
FOREIGN KEY (ID_medicamento) REFERENCES Medicamento(idMed)
);

################################################################################################
# 2. Rellene las tablas creadas con algunos datos de ejemplo.
#################################################################################################
INSERT INTO MEDICAMENTO (idMed,nombre,precio,descripcion) VALUES 
-- 4 Medicamentos de precios variados
 (1,'Paracetamol',3,'Analgesico y Antipiretico'),
 (2,'Blincyto',4160,'Tratamiento nuevo de Leucemia'),
 (3,'Insulina',52,'Tratamiento de Diabetes'),
 (4,'Ibuprofeno',6,'Antiinflamatorio');

INSERT INTO FARMACIA (idFarm,nombre,direccion) VALUES
-- 2 Sucursales distintas
(1,'Farmacia La Salud','C\ Marte, 47001 Valladolid'),
(2,'Farmacia Hnos. Perez','C\ Padilla 34473 Palencia');

INSERT INTO INVENTARIO (idInv,farmId,medId,stock) VALUES
-- Cantidades de cada medicamento para cada sucursal, a la primera le falta stock de Bilicynto
(1,1,1,10),
(2,1,2,0),
(3,1,3,1),
(4,1,4,10),
(5,2,1,12),
(6,2,2,1),
(7,2,3,5),
(8,2,4,15);

INSERT INTO PEDIDO (idPedido,fecha,farmaciaId) VALUES
-- 2 pedidos, uno para cada sucursal
(1,'2023-04-21',1),
(2,'2023-03-21',2);

INSERT INTO DETALLE_PEDIDO (pedId,cantidad,precio,ID_medicamento) VALUES
-- El primer pedido tiene 2 medicamentos, el segundo 1
(1,1,4200,2),
(1,1,55,3),
(2,5,6,4);

INSERT INTO PEDIDO_MEDICAMENTO (idPedidoMed,medId,pedId) VALUES
(1,2,1),
(2,3,1),
(3,4,2);

INSERT INTO CLIENTE (idCliente,nombre) VALUES
-- Dos clientes registrados
(1,'Maria Perez'),
(2,'Fernando Martinez');

INSERT INTO COMPRA (idCompra,clienteId,medicamentoId,fecha,precio) VALUES
-- Un cliente hizo 11 compras, el otro solo una
(1,1,1,'2022-01-01',3),
(2,1,1,'2022-01-10',3),
(3,1,1,'2022-01-20',3),
(4,1,1,'2022-01-30',3),
(5,1,1,'2022-03-01',3),
(6,1,1,'2022-04-01',3),
(7,1,1,'2022-05-02',3),
(8,1,1,'2022-06-03',3),
(9,1,1,'2022-07-03',3),
(10,1,1,'2022-08-03',3),
(11,1,1,'2022-08-12',3),
(12,2,4,'2023-02-02',6);

#################################################################################################
# 3. Una vez poblada la base de datos con algunos ejemplos, realice las siguientes consultas:
################################################################################################# 


# 3.1.	Seleccionar los nombres y precios de todos los medicamentos.

select nombre,precio from medicamento;

# 3.2.	Seleccionar todos los medicamentos que tengan un precio mayor a 50 euros.

select * from medicamento where precio>50;

# 3.3.	Seleccionar todos los medicamentos que tengan un precio mayor a 50 euros y 
#       que estén disponibles en inventario para todas las sucursales.
-- Medicamentos de precio > 50 de los que excluimos aquellos en los que alguna sucursal tenga stock 0

(select * from medicamento where precio>50) 
except
(select medicamento.idMed, medicamento.nombre, medicamento.precio, medicamento.descripcion from medicamento, inventario where inventario.stock = 0 and inventario.medId = medicamento.idMed);

# 3.4.	Seleccionar todos los pedidos realizados por una sucursal en particular.
-- Mostramos los que ha hecho la sucursal 'Farmacia La Salud'

select pedido.idPedido, pedido.fecha, pedido.farmaciaId from pedido, farmacia where pedido.farmaciaId=farmacia.idFarm and farmacia.nombre = 'Farmacia La Salud';

# 3.5.	Seleccionar todos los pedidos realizados por una sucursal en particular en 
#       una tabla de pedidos que estén pendientes de ser recibidos. Se asume que un 
#       pedido está pendiente de entrega cuando la fecha del pedido es inferior a una semana 
#       respecto a la fecha actual.

select pedido.idPedido, pedido.fecha, pedido.farmaciaId from pedido, farmacia where pedido.farmaciaId=farmacia.idFarm and farmacia.nombre = 'Farmacia La Salud' and DATEDIFF(NOW(),pedido.fecha) < 7;


# 3.6.	Seleccionar el nombre y la cantidad de todos los medicamentos que ha pedido 
#       una sucursal en un periodo de tiempo específico.

-- Mostramos las cantidades que ha pedido la sucursal 'Farmacia Hnos. Perez' en lo últimos 90 días

select medicamento.nombre, detalle_pedido.cantidad 
from medicamento, detalle_pedido, pedido 
where pedido.farmaciaId = 2  and detalle_pedido.pedId = pedido.idPedido and medicamento.idMed = detalle_pedido.ID_medicamento and DATEDIFF(NOW(),pedido.fecha) < 90;

# 3.7.	Seleccionar todos los medicamentos que estén disponibles en inventario 
#       y que hayan sido vendidos más de 10 veces.

select distinct medicamento.idMed, medicamento.nombre, medicamento.precio, medicamento.descripcion 
from medicamento,inventario 
where medicamento.idMed = inventario.medId and inventario.stock !=0 and medicamento.idMed in (select compra.medicamentoId from compra group by compra.medicamentoId having count(compra.medicamentoId)>10);

# 3.8.	Seleccionar el nombre y la descripción de todos los medicamentos que tengan 
#       una descripción que contenga la palabra "nuevo" en una tabla de productos.

select nombre, descripcion from medicamento where descripcion like '%nuevo%';


################################################################################################################# 
# 4.	Implemente el disparador que se presenta en el enunciado. A continuación, debe realizar 
#       diferentes actualizaciones del stock de medicamentos para comprobar el correcto funcionamiento 
#       del disparador
#################################################################################################################

-- Creo relación que indica la cantidad mínima a mantener de cada medicamento por sucursal
DROP TABLE IF EXISTS NIVELMIN;
CREATE TABLE NIVELMIN(
IdMed int UNSIGNED,
IdFarm int UNSIGNED,
nivel int UNSIGNED,
PRIMARY KEY (IdMed, IdFarm),
FOREIGN KEY (IdMed) REFERENCES Medicamento(idMed),
FOREIGN KEY (IdFarm) REFERENCES Farmacia(idFarm)
);

-- Rellenamos la tabla, canntidad mínima 1 para todos los medicamentos y sucursales

INSERT INTO NIVELMIN (IdMed,IdFarm,nivel) VALUES
(1,1,1),
(2,1,1),
(3,1,1),
(4,1,1),
(1,2,1),
(2,2,1),
(3,2,1),
(4,2,1);

-- Creo relación que indica la cantidad mínima a pedir de cada medicamento por sucursal
DROP TABLE IF EXISTS CANTIDADPEDIDO;
CREATE TABLE CANTIDADPEDIDO(
IdMedic int UNSIGNED,
IdFarma int UNSIGNED,
cantidad int UNSIGNED,
PRIMARY KEY (IdMedic, IdFarma),
FOREIGN KEY (IdMedic) REFERENCES Medicamento(idMed),
FOREIGN KEY (IdFarma) REFERENCES Farmacia(idFarm)
);

-- Cantidad mínima a pedir 5 para todos los medicamentos y sucursales

INSERT INTO CANTIDADPEDIDO (IdMedic,IdFarma,cantidad) VALUES
(1,1,5),
(2,1,5),
(3,1,5),
(4,1,5),
(1,2,5),
(2,2,5),
(3,2,5),
(4,2,5);

-- Mostramos contenido de las tablas PEDIDO, PEDIDO_MEDICAMENTO y DETALLE_PEDIDO antes de implementar el disparador

select * from pedido;
select * from pedido_medicamento;
select * from detalle_pedido;


DELIMITER $$
create trigger pedido_nuevo after update on inventario
for each row
begin
declare nuevoidPedido int UNSIGNED;
declare nuevoidPedidoMed int UNSIGNED;
declare cantidadPedir int UNSIGNED;
declare precioPedir int UNSIGNED;
declare fechaActual date;
if ((NEW.stock <= (select nivel
 						from nivelmin
 						where nivelmin.IdMed = OLD.medId and nivelmin.IdFarm = OLD.farmId)) and (OLD.stock > (select nivel
																											from nivelmin
																										where nivelmin.IdMed = OLD.medId and nivelmin.IdFarm = OLD.farmId)))
 then 
set @nuevoidPedido = (select max(idPedido)+1 from pedido);
set @nuevoidPedidoMed = (select max(idPedidoMed)+1 from pedido_medicamento);
set @cantidadPedir = (select max(cantidad) from cantidadpedido where cantidadpedido.IdMedic = OLD.medId);
set @precioPedir = (select max(precio) from medicamento where medicamento.idMed = OLD.medId);
set @fechaActual = NOW();
insert into pedido VALUES (@nuevoidPedido,@fechaActual,OLD.farmId);
insert into pedido_medicamento VALUES (@nuevoidPedidoMed,OLD.medId,@nuevoidPedido);
insert into detalle_pedido VALUES (@nuevoidPedido,@cantidadPedir,@precioPedir,OLD.medId);
end if;
end$$

-- Reducimos el stock de ibuprofeno de la primera sucursal a 0

UPDATE inventario 
SET inventario.stock = 0
where inventario.farmId=1 and inventario.medId=4;

-- Volvemos a mostrar el contenido de las tablas PEDIDO, PEDIDO_MEDICAMENTO y DETALLE_PEDIDO tras implementar el disparador
-- Comprobamos que hay un nuevo pedido para la primera sucursal, y en su detalle aparece la cantidad de ibuprofeno estipulada

select * from pedido;
select * from pedido_medicamento;
select * from detalle_pedido;




