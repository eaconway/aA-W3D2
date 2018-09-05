PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

INSERT INTO
  users (fname, lname)
VALUES
  ("Ned", "Ruggeri"), ("Kush", "Patel"), ("Earl", "Cat");
  
  
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  
  FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO
  questions (title, body, author_id)
SELECT
  "Ned Question", "NED NED NED", 1
FROM
  users
WHERE
  users.fname = "Ned" AND users.lname = "Ruggeri";

INSERT INTO
  questions (title, body, author_id)
SELECT
  "Kush Question", "KUSH KUSH KUSH", users.id
FROM
  users
WHERE
  users.fname = "Kush" AND users.lname = "Patel";
  
INSERT INTO
  questions (title, body, author_id)
SELECT
  "LEAGUE AND IT", "THIS AND THAT", users.id
FROM
  users
WHERE
  users.fname = "Kush" AND users.lname = "Patel";

INSERT INTO
  questions (title, body, author_id)
SELECT
  "Earl Question", "MEOW MEOW MEOW", users.id
FROM
  users
WHERE
  users.fname = "Earl" AND users.lname = "Cat";
-- 
-- -- INSERT INTO
-- --   questions (title, body, author_id)
-- -- VALUES
-- --   ('Help SQL!!', 'My sql not work', (SELECT id FROM users WHERE fname = 'Darren' AND lname = 'Adkinson')),
-- --   ('League LOVE!', 'Best game ever', (SELECT id FROM users WHERE fname = 'Eric' AND lname = 'Conway')); 
-- -- 
  
CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  author_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,
  
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

INSERT INTO
  question_follows (author_id, questions_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"),
  (SELECT id FROM questions WHERE title = "Earl Question")),

  ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  (SELECT id FROM questions WHERE title = "Earl Question")
);

-- INSERT INTO
--   question_follows (author_id, question_id)
-- VALUES
--   ((SELECT id FROM users WHERE fname = 'Eric' AND lname = 'Conway'),(SELECT id FROM questions WHERE title = 'Help SQL!!')),
--   ((SELECT id FROM users WHERE fname = 'Darren' AND lname = 'Adkinson'),(SELECT id FROM questions WHERE title = 'League LOVE!'));

  
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  questions_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  author_id INTEGER NOT NULL,
  
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

INSERT INTO
  replies (questions_id, parent_reply_id, author_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = "Earl Question"),
  NULL,
  (SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"),
  "Did you say NOW NOW NOW?"
);

INSERT INTO
  replies (questions_id, parent_reply_id, author_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = "Earl Question"),
  (SELECT id FROM replies WHERE body = "Did you say NOW NOW NOW?"),
  (SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  "I think he said MEOW MEOW MEOW."
);


CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,
  
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

INSERT INTO
  question_likes (author_id, questions_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  (SELECT id FROM questions WHERE title = "Earl Question")
);

-- and here is the lazy way to add some seed data:
INSERT INTO question_likes (author_id, questions_id) VALUES (1, 1);
INSERT INTO question_likes (author_id, questions_id) VALUES (1, 2);
INSERT INTO question_likes (author_id, questions_id) VALUES (2, 2);
INSERT INTO question_likes (author_id, questions_id) VALUES (3, 2);
