CREATE TABLE IF NOT EXISTS `jobgarage_vehicles` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `license` varchar(50) DEFAULT NULL,
    `citizenid` varchar(50) DEFAULT NULL,
    `vehicle` varchar(50) DEFAULT NULL,
    `hash` varchar(50) DEFAULT NULL,
    `plate` varchar(15) NOT NULL,
    `garage` varchar(50) DEFAULT 'none',
    PRIMARY KEY (`id`),
    KEY `plate` (`plate`),
    KEY `citizenid` (`citizenid`),
    KEY `license` (`license`)
) ENGINE=InnoDB AUTO_INCREMENT=1;
