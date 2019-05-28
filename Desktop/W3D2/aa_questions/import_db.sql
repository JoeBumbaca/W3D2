PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255),
  lname VARCHAR(255)
);


CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR,
  body VARCHAR,
  author_id INTEGER,

  FOREIGN KEY (author_id) REFERENCES users(id)
);




CREATE TABLE question_follows (
  question_id INTEGER,
  user_id INTEGER,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);



CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  reply VARCHAR,
  body VARCHAR,
  question_id INTEGER,
  parent_reply INTEGER,
  user_id INTEGER,
  

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (parent_reply) REFERENCES replies(id)
);



CREATE TABLE question_likes (
  question_id INTEGER,
  user_id INTEGER,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO 
  users (fname,lname)
VALUES
  ('Joe', 'Bumbaca'),
  ('Kavya', 'Kumar');

INSERT INTO
  questions (title, body, author_id)
VALUES 
  ('Create Tables', 'How do I create a table', (SELECT id FROM users WHERE fname = 'Joe')),
  ('ORM', 'What is an ORM', (SELECT id FROM users WHERE fname = 'Kavya'));

INSERT INTO
  replies (reply, body, question_id, parent_reply, user_id)
VALUES
  ('Create Tables', 'Look online', 
  (SELECT id FROM questions WHERE title = 'Create Tables'),NULL,
  (SELECT id FROM users WHERE fname = 'Joe')),
  ('ORM', 'This is an ORM',
  (SELECT id FROM questions WHERE title = 'ORM'),NULL,
  (SELECT id FROM users WHERE fname = 'Kavya')
  );