CREATE TABLE users.access_log
(
  aid INTEGER
, site_id INTEGER
, count INTEGER
, date TIMESTAMP
)
;

INSERT INTO users.access_log(aid, site_id, count, date) VALUES (1,1,3,'2016-05-10');
INSERT INTO users.access_log(aid, site_id, count, date) VALUES (2,3,2,'2016-05-13');
INSERT INTO users.access_log(aid, site_id, count, date) VALUES (3,1,5,'2016-05-14');
INSERT INTO users.access_log(aid, site_id, count, date) VALUES (4,2,4,'2016-05-14');
INSERT INTO users.access_log(aid, site_id, count, date) VALUES (5,5,4,'2016-05-14');
INSERT INTO users.access_log(aid, site_id, count, date) VALUES (6,5,5,'2016-05-12');
INSERT INTO users.access_log(aid, site_id, count, date) VALUES (6,1,1,'9999-12-12');
INSERT INTO users.access_log(aid, site_id, count, date) VALUES (6,5,5,'2016-05-12');
