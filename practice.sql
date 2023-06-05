-- 従業員番号（emp_no）が20000の人のファーストネームとラストネームを表示
SELECT first_name,last_name
FROM employees
WHERE emp_no = '20000';

-- 誕生日が1959年1月の人のレコードを抽出せよ
SELECT
  COUNT(*)
FROM
  employees
WHERE
  birth_date BETWEEN '1959-01-01' AND '1959-01-31';

-- ファーストネームが「Akemi」で性別が女性のレコードを抽出せよ
SELECT
  *
FROM
  employees
WHERE
  first_name ='Akemi'
  AND gender = 'F';

-- 雇用日（hire_date）が古い順の上位100位のレコードを抽出せよ
SELECT
  *
FROM
  employees
ORDER BY hire_date ASC
LIMIT 100;

-- 雇用日（hire_date）が新しい順の上位100位のレコードを抽出せよ
SELECT
  *
FROM
  employees
ORDER BY hire_date DESC
LIMIT 100;

-- 年齢が高い順で、年齢が同じ場合は従業員番号が新しい順で、上位100位のレコードを抽出せよ
SELECT
  *
FROM
  employees
ORDER BY
  birth_date ASC,
  emp_no DESC
LIMIT 100;
-- メモ
-- ORDER BYは結果に対して行われる



mysql> SELECT * FROM salaries LIMIT 3;
+--------+--------+------------+------------+
| emp_no | salary | from_date  | to_date    |
+--------+--------+------------+------------+
|  10001 |  70000 | 1986-06-26 | 1987-06-26 |
|  10001 |  62102 | 1987-06-26 | 1988-06-25 |
|  10001 |  66074 | 1988-06-25 | 1989-06-25 |
+--------+--------+------------+------------+
-- salariesテーブルのレコード数を求めよ
SELECT
  COUNT(*)
FROM
  salaries;
-- from_date が1986年6月26日の従業員の最大給与を求めよ
SELECT
  MAX(salary)
FROM
  salaries
WHERE
  from_date = '1986-06-26';
-- to_date が1991年6月26日の従業員の平均給与を少数第1桁で求めよ
SELECT
  ROUND(AVG(salary),1)
FROM
  salaries
WHERE
  to_date = '1991-06-26';

-- 従業員番号10001から10010の従業員ごとの最小給与と最大給与を求めよ
SELECT
  emp_no,MIN(salary),MAX(salary)
FROM
  salaries
WHERE
  emp_no BETWEEN '10001' AND '10010'
GROUP BY
  emp_no;

-- 従業員番号10001から10010の従業員ごとの勤務開始日と勤務終了日を求めよ。なお勤務中の場合、勤務終了日は 9999-01-01 と出力せよ
SELECT
  emp_no,MIN(from_date),MAX(to_date)
FROM
  salaries
WHERE
  emp_no BETWEEN '10001' AND '10010'
GROUP BY
  emp_no;

-- 従業員番号10001から10100の従業員のうち、最小給与が40000を下回っている従業員の従業員番号とその最小給与を出力せよ
SELECT
  emp_no,MIN(salary)
FROM
  salaries
WHERE
  emp_no BETWEEN '10001' AND '10100'
GROUP BY
  emp_no
HAVING
  MIN(salary) < '60000';
-- HAVINGはグルーピングしたレコードに対して、さらに絞り込みをおこなう

-- 従業員番号10001から10100の従業員のうち、勤務が終了している従業員の従業員番号と最後の勤務終了日を出力せよ。なお勤務中の場合、勤務終了日は 9999-01-01  となる
SELECT
  emp_no,MAX(to_date)
FROM
  salaries
WHERE
  emp_no BETWEEN '10001' AND '10100'
GROUP BY
  emp_no
HAVING
  MAX(to_date) <> '9999-01-01';


-- 従業員番号10001から10010の従業員ごとに、姓名と、いつからいつまで給与がいくらだったかを求めよ
SELECT
  e.emp_no,
  e.first_name,
  e.last_name,
  MIN(s.from_date),
  MAX(s.to_date),
  SUM(s.salary)
FROM
  employees AS e INNER JOIN salaries AS s
    ON e.emp_no  = s.emp_no
WHERE
  e.emp_no BETWEEN '10001' AND '10010'
GROUP BY
  e.emp_no;

-- 部署(departments)毎に、部署名と、歴代のマネージャーの姓名及びマネージャー任命期間（いつからいつまでマネージャーであったか）を求めよ
SELECT
  d.dept_name,
  e.first_name,
  e.last_name,
  m.from_date,
  m.to_date
FROM
  departments AS d INNER JOIN dept_manager AS m
    ON d.dept_no = m.dept_no
      INNER JOIN employees AS e
        ON m.emp_no = e.emp_no
;

-- 平均の2倍以上の給与をもらっている従業員の従業員番号を重複なく求めよ
SELECT
  DISTINCT(emp_no)
FROM
  salaries
WHERE
  salary > (
    SELECT
      ROUND(AVG(salary),0) *2
    FROM
      salaries
  )
;


-- 従業員番号10100から10200の従業員の中で、それぞれの性別で最も若い年齢の人の性別、誕生日、従業員番号、ファーストネーム、ラストネームを求めよ
SELECT
  gender,
  birth_date,
  emp_no,
  first_name,
  last_name
FROM
  employees AS e1
WHERE
  emp_no BETWEEN 10100 AND 10200
  AND birth_date = (
                     SELECT
                       MAX(birth_date)
                     FROM
                       employees AS e2
                     WHERE
                       emp_no BETWEEN 10100 AND 10200
                       AND e1.gender = e2.gender
                   );

-- クエリの流れ

-- 主クエリでemployees(e1)テーブルがスキャンされる。まず最初にemp_noが10001の行がスキャンされることを考えてみる。
employeesテーブル
+--------+------------+------------+-----------+--------+------------+
| emp_no | birth_date | first_name | last_name | gender | hire_date  |
+--------+------------+------------+-----------+--------+------------+
|  10001 | 1953-09-02 | Georgi     | Facello   | M      | 1986-06-26 |
|  10002 | 1964-06-02 | Bezalel    | Simmel    | F      | 1985-11-21 |
+--------+------------+------------+-----------+--------+------------+
-- Where句のbirth_dateにe1の一行目のbirth_dateの値(1953-09-02)が入る。
-- ここからサブクエリが実行されます。このサブクエリの目的は、現在のスキャン行の性別と同じ性別の行の中で最も新しいbirth_dateを見つけること。
-- サブクエリのWhere句のe1.genderにはe1の一行目のgenderの値(M)が入る。このため、サブクエリはe2テーブルのgenderがMの行のみが対象になる。
-- MAX(birth_date)は、これらの行の中で最も新しいbirth_dateを見つけます。例えば、以下のような行が該当する
+--------+------------+------------+-----------+--------+------------+
| emp_no | birth_date | first_name | last_name | gender | hire_date  |
+--------+------------+------------+-----------+--------+------------+
| 10001 | 1953-09-02  | Georgi     | Facello    | M     | 1986-06-26 |
| 10003 | 1959-12-03  | Parto      | Bamford    | M     | 1986-08-28 |
| 10004 | 1954-05-01  | Chirstian  | Koblick    | M     | 1986-12-01 |
+--------+------------+------------+-----------+--------+------------+
-- これらの行の中で最も新しいbirth_dateは1959-12-03がサブクエリの結果となる
-- そして、サブクエリの結果birth_date（1959-12-03）が主クエリのWhere句のbirth_date（1953-09-02）と一致するか確認される。一致しなければ、現在のスキャン行は結果に含まれない。
-- その後、e1の次の行（emp_noが10002の行など）がスキャンされ、上記の手順が再び繰り返されます。このように、主クエリの各行がスキャンされ処理される。

-- ポイントとしては
-- 主クエリのテーブルが一行ごとにスキャンされるため、一行スキャンされるたびにサブクエリが毎回実行されている。
-- サブクエリの相関サブクエリには主クエリの現在のスキャン行の値が入る。


-- 退職者も含む全従業員数を求めよう
SELECT
  COUNT(*) AS all_employees_numbers
FROM
  employees;

-- 現在何らかの部署に配属中の従業員数を求めよう
SELECT
  COUNT(*) AS number_of_assigned_emp
FROM
  current_dept_emp
WHERE
  to_date = '9999-01-01';

-- 現在どの部署にも配属していない（退職中の）従業員数を求めよう
SELECT
  COUNT(*) AS number_of_not_assigned_emp
FROM
  current_dept_emp
WHERE
  to_date <> '9999-01-01';

-- 各従業員の最高給与の上位30位の従業員番号と最高給与金額を求めよう
SELECT
  emp_no,MAX(salary) AS highest_salary_of_emp
FROM
  salaries
GROUP BY
  emp_no
ORDER BY
  highest_salary_of_emp DESC
LIMIT 30;

-- 各従業員の最低給与の下位30位の従業員番号と最低給与金額を求めよう
SELECT
  emp_no,MIN(salary) AS lowest_salary_of_emp
FROM
  salaries
GROUP BY
  emp_no
ORDER BY
  lowest_salary_of_emp ASC
LIMIT 30;

-- 従業員番号10010から10100の従業員で現在役職を保持している従業員の、従業員番号、ファーストネーム、ラストネーム、現在の役職名（title）を求めよう
SELECT
  t.emp_no,first_name,last_name,title
FROM
  titles AS t INNER JOIN employees AS e
    ON t.emp_no = e.emp_no
WHERE
  t.emp_no BETWEEN '10010' AND '10100'
  AND to_date = '9999-01-01';

-- 全部署の部署名およびその部署に現在在籍している従業員の最高給与を求めよう
SELECT
  d.dept_name,MAX(s.salary)
FROM
  current_dept_emp AS cde INNER JOIN departments AS d
    ON cde.dept_no = d.dept_no INNER JOIN salaries AS s
      ON cde.emp_no = s.emp_no
GROUP BY
  d.dept_name
;

-- 全部署の部署名およびその部署の現在マネージャーの現在の給与を求めよう
SELECT
  d.dept_name,
  s.salary AS current_manager_current_salary
FROM
  dept_manager AS dm
    INNER JOIN departments AS d
      ON dm.dept_no = d.dept_no
    INNER JOIN salaries AS s
      ON dm.emp_no = s.emp_no
WHERE
  dm.to_date = '9999-01-01'
  AND s.to_date = '9999-01-01'
;

-- 全部署の部署名およびその部署の現在マネージャーの最高給与を求めよう
SELECT
  d.dept_name,
  MAX(s.salary) AS current_manager_max_salary
FROM
  dept_manager AS dm
    INNER JOIN departments AS d
      ON dm.dept_no = d.dept_no
    INNER JOIN salaries AS s
      ON dm.emp_no = s.emp_no
WHERE
  dm.to_date = '9999-01-01'
GROUP BY
  d.dept_name
;
