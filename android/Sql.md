title:  Sql练习
date: 2018年9月5日00:12:49
categories: SQL
tags: 
	 - Sql
cover_picture: /images/common.png
---

##### 基础练习

1. 查询Student表中的所有记录的Sname、Ssex和Class列。

   ```sql
   SELECT sname,ssex,class From students 
   ```

2. 查询教师所有的单位即不重复的Depart列。

   ```sql
   SELECT DISTINCT depart From teachers
   ```

3. 查询Student表的所有记录。

   ```sql
   SELECT *  From students
   ```

4. 查询Score表中成绩在60到80之间的所有记录。

   ```sql
   SELECT *  From scores WHERE degree BETWEEN 60 And 80 
   ```

5. 查询Score表中成绩为85，86或88的记录。

   ```sql
   SELECT *  From scores WHERE degree = 85 or degree = 86 or degree =88 
   
   SELECT *  From scores WHERE degree IN (85,86,88)
   ```

6. 查询Student表中“95031”班或性别为“女”的同学记录。

   ```sql
   SELECT *  From students WHERE class = '95031' OR ssex = '女'
   ```

7. 以Class降序查询Student表的所有记录。

   ```sql
   SELECT *  From students ORDER BY class DESC
   ```

8. 以Cno升序、Degree降序查询Score表的所有记录。

   ```sql
   SELECT *  From scores ORDER BY cno ASC,degree DESC
   ```

9. 查询“95031”班的学生人数。

   ```sql
   SELECT COUNT(*)  From students WHERE class = '95031'
   
   SELECT COUNT(1)  AS StuNum FROM Students WHERE Class =  '95031'
   ```

10. 查询Score表中的最高分的学生学号和课程号。

    ```sql
      SELECT sno,cno From scores ORDER BY degree DESC LIMIT 1
      
      SELECT MAX(degree) From scores //查询最大值
    ```

11. 查询‘3-105’号课程的平均分。

    ```sql
    SELECT AVG(degree) From scores WHERE cno = '3-105'
    ```

12. 查询Score表中至少有5名学生选修的并以3开头的课程的平均分数。

    ```sql
    SELECT cno,AVG(degree) From scores WHERE cno LIKE '3%' GROUP BY  cno HAVING COUNT(sno) > 5
    ```

13. 查询最低分大于70，最高分小于90的Sno列。

    ```sql
    SELECT sno From scores GROUP BY sno HAVING MIN(degree) > 70 And MAX(degree) < 90 
    ```

14. 查询所有学生的Sname、Cno和Degree列。

    ```sql
    SELECT st.sname,sc.cno,sc.degree From students st JOIN scores sc On sc.sno = st.sno
    ```

15. 查询所有学生的Sno、Cname和Degree列。

    ```sql
    SELECT st.sname,sc.cno,sc.degree From students st JOIN scores sc On sc.sno = st.sno
    
    SELECT st.sname,sc.cno,sc.degree From students st JOIN scores sc On (sc.sno = st.sno)
    ```

16. 查询所有学生的Sname、Cname和Degree列。

    ```sql
    SELECT st.sname,sc.cno,sc.degree From students st JOIN scores sc On sc.sno = st.sno
    
    SELECT st.sname,sc.cno,sc.degree From students st JOIN scores sc On (sc.sno = st.sno)
    ```

17. 查询“95033”班所选课程的平均分。

    ```sql
    SELECT courses.cname,AVG(degree) FROM scores JOIN students ON students.sno = scores.sno JOIN courses ON scores.cno = courses.cno WHERE students.class = '95033' GROUP BY courses.cno;
    ```

18. 假设使用如下命令建立了一个grade表：

    ```sql
    CREATE TABLE grade(low TINYINT,upp TINYINT,rank CHAR(1));
    
    INSERT INTO grade VALUES(90,100,'A');
    
    INSERT INTO grade VALUES(80,89,'B');
    
    INSERT INTO grade VALUES(70,79,'C');
    
    INSERT INTO grade VALUES(60,69,'D');
    
    INSERT INTO grade VALUES(0,59,'E');
    ```

    现查询所有同学的Sno、Cno和rank列。

    ```sql
    SELECT sc.sno,sc.cno,sc.degree,g.rank FROM scores sc JOIN grade g ON (sc.degree >= g.low AND sc.degree <= g.upp) ORDER BY g.rank ASC,sc.sno ASC;
    ```

19. 查询选修“3-105”课程的成绩高于“109”号同学成绩的所有同学的记录。

    ```sql
    SELECT sc.sno,sc.degree FROM students st JOIN scores sc ON sc.sno = st.sno WHERE sc.cno = '3-105' AND sc.degree > (SELECT sc.degree FROM scores sc WHERE sc.sno = '109' AND sc.cno = '3-105');
    
    SELECT s1.Sno,s1.Degree FROM Scores AS s1 INNER JOIN Scores AS s2 ON (s1.Cno = s2.Cno AND s1.Degree > s2.Degree) WHERE s1.Cno = '3-105' AND s2.Sno = '109' ORDER BY s1.Sno;
    ```

20. 查询score中选学一门以上课程的同学中分数为非最高分成绩的记录。

    ```sql
    SELECT * From scores GROUP BY sno HAVING COUNT(sno) > 1 AND degree != MAX(degree);
    ```

21. 查询成绩高于学号为“109”、课程号为“3-105”的成绩的所有记录。

    ```sql
    SELECT * From scores WHERE cno = '3-105' AND degree > (SELECT degree FROM scores WHERE sno = '109' AND cno = '3-105');
    
    SELECT s1.Sno,s1.Degree FROM Scores AS s1 INNER JOIN Scores AS s2 ON (s1.Cno = s2.Cno AND s1.Degree > s2.Degree) WHERE s1.Cno = '3-105' AND s2.Sno = '109' ORDER BY s1.Sno;
    ```

22. 查询和学号为108的同学同年出生的所有学生的Sno、Sname和Sbirthday列。

    ```sql
    SELECT st.sno,st.sname,st.sbirthday FROM students st WHERE YEAR (st.Sbirthday) = (SELECT YEAR(sbirthday) FROM students WHERE sno = '108') AND st.sno != '108';
    
    SELECT s1.Sno,s1.Sname,s1.Sbirthday FROM Students AS s1 INNER JOIN Students AS s2 ON (YEAR (s1.Sbirthday) = YEAR (s2.Sbirthday)) WHERE s2.Sno = '108' AND s1.sno != '108';
    ```

23. 查询“张旭“教师任课的学生成绩。

    ```sql
    SELECT sc.degree FROM scores sc JOIN courses c On sc.cno = c.cno JOIN teachers t On t.tno = c.tno WHERE t.tname = '张旭';
    ```

24. 查询选修某课程的同学人数多于5人的教师姓名。

    ```sql
    SELECT cno From scores GROUP BY cno HAVING COUNT(sno) > 5;
    
    SELECT t.tname FROM scores sc JOIN courses c ON c.cno = sc.cno JOIN teachers t ON t.tno = c.tno GROUP BY c.tno HAVING(count(sno) > 5);
    	
    SELECT DISTINCT t.tname FROM scores sc JOIN courses c ON sc.cno = c.cno JOIN teachers t On t.tno = c.tno WHERE c.cno in (SELECT cno From scores GROUP BY cno HAVING COUNT(sno) > 5);
    ```

25. 查询95033班和95031班全体学生的记录。

    ```sql
    SELECT * FROM Students WHERE Class IN ('95033','95031') ORDER BY Class;
    ```

26. 查询存在有85分以上成绩的课程Cno.

    ```sql
    SELECT DISTINCT Cno FROM Scores WHERE Degree > 85;
    ```

27. 查询出“计算机系“教师所教课程的成绩表。

    ```sql
    SELECT sc.degree,t.depart FROM scores sc Join courses c On c.cno = sc.cno JOIN teachers t On t.tno = c.tno WHERE t.depart = '计算机系';
    ```

28. 查询“计算机系”与“电子工程系“不同职称的教师的Tname和Prof。

    ```sql
    SELECT Tname,Prof FROM Teachers WHERE Depart='计算机系' AND Prof NOT IN( SELECT DISTINCT Prof FROM Teachers WHERE Depart='电子工程系');
    			
    SELECT tname,prof FROM teachers WHERE depart ='电子工程系' And prof NOT IN(SELECT DISTINCT prof FROM teachers WHERE depart = '计算机系');
    ```

29. 查询选修编号为“3-105“课程且成绩至少高于选修编号为“3-245”的同学的Cno、Sno和Degree,并按Degree从高到低次序排序。

    ```sql
    SELECT sc.cno,sc.sno,sc.degree FROM scores sc WHERE sc.cno = '3-105' AND sc.degree > ANY (SELECT degree FROM scores WHERE cno = '3-245') ORDER BY sc.degree DESC;	
    ```

30. 查询选修编号为“3-105”且成绩高于选修编号为“3-245”课程的同学的Cno、Sno和Degree.

    ```sql
    SELECT sc.cno,sc.sno,sc.degree FROM scores sc WHERE sc.cno = '3-105' AND sc.degree >ALL(SELECT  degree FROM scores WHERE cno = '3-245') ORDER BY sc.degree DESC;
    ```

31. 查询所有教师和同学的name、sex和birthday.

    ```sql
    SELECT tname,tsex,tbirthday From teachers UNION Select sname,ssex,sbirthday FROM students;
    ```

32. 查询所有“女”教师和“女”同学的name、sex和birthday.

    ```sql
    SELECT tname,tsex,tbirthday From teachers WHERE tsex = '女' UNION Select sname,ssex,sbirthday FROM students WHERE ssex = '女';
    ```

33. 查询成绩比该课程平均成绩低的同学的成绩表。

    ```sql
    SELECT sc.* From scores sc WHERE sc.degree < (SELECT AVG(degree) FROM scores WHERE cno = sc.cno) ORDER BY sc.sno;
    
    SELECT s1.* FROM Scores AS s1 JOIN (SELECT Cno,AVG(Degree) AS aDegree FROM Scores GROUP BY Cno) s2 ON(s1.Cno=s2.Cno AND s1.Degree<s2.adegree) ORDER BY s1.sno;
    ```

34. 查询所有任课教师的Tname和Depart.

    ```sql
    SELECT te.tname,te.depart FROM teachers te Where te.tno In (SELECT tno From courses);
    
    SELECT te.tname,te.depart FROM teachers te Where te.tno In (SELECT tno From courses WHERE cno IN (SELECT sc.cno From scores sc ));
    
    SELECT Tname,Depart FROM Teachers WHERE Tno IN(SELECT Tno FROM Courses);
    ```

35. 查询所有未讲课的教师的Tname和Depart. 

    ```sql
    SELECT te.tname,te.depart FROM teachers te Where te.tno not In (SELECT tno From courses);
    SELECT te.tname,te.depart FROM teachers te Where NOT EXISTS (SELECT tno From courses WHERE tno = te.tno);
    
    SELECT Tname,Depart FROM Teachers WHERE Tno not IN(SELECT Tno FROM Courses);
    SELECT Tname,Depart FROM Teachers WHERE NOT EXISTS (SELECT tno FROM courses WHERE tno = teachers.tno);
    ```

36. 查询至少有2名男生的班号。

    ```sql
    SELECT st.class,COUNT(sno) boycount FROM students st WHERE st.ssex ='男' GROUP BY st.class HAVING boycount >= 2;
    
    SELECT Class,COUNT(1) AS boyCount FROM Students WHERE Ssex='男' GROUP BY Class HAVING boyCount>=2;
    ```

37. `查询Student表中不姓“王”的同学记录。`

    ```sql
    SELECT * FROM students WHERE sname not LIKE '王%';
    ```

38. 查询Student表中每个学生的姓名和年龄。

    ```sql
    SELECT sname,sbirthday FROM students ;
    
    SELECT Sname,YEAR(NOW())-YEAR(Sbirthday) AS Sage FROM Students;
    ```

39. 查询Student表中最大和最小的Sbirthday日期值。

    ```sql
    SELECT MAX(DAY(sbirthday)) maxDay,MIN(DAY(sbirthday)) minDay FROM students ;  
    
    SELECT MIN(Sbirthday),MAX(Sbirthday) FROM Students;
    ```

40. 以班号和年龄从大到小的顺序查询Student表中的全部记录。

    ```sql
    SELECT * FROM students GROUP BY class DESC, sbirthday ASc;
    ```

41. 查询“男”教师及其所上的课程。

    ```sql
    SELECT te.*,c.* FROM teachers te JOIN courses c On c.tno = te.tno WHERE te.tsex ='男';
    ```

42. 查询最高分同学的Sno、Cno和Degree列。

    ```sql
    SELECT sno,cno,degree FROM scores WHERE degree = (SELECT MAX(degree) FROM scores);
    
    SELECT * FROM Scores GROUP BY Cno HAVING Degree=Max(Degree);
    ```

43. 查询和“李军”同性别的所有同学的Sname.

    ```sql
    SELECT sname FROM students WHERE ssex = (SELECT s1.ssex FROM students s1 WHERE s1.sname = '李军') AND sname != '李军'; 
    
    SELECT s1.sname From students s1 JOIN students s2 On (s1.ssex = s2.ssex) WHERE s2.sname = '李军' And s1.sname != '李军';
    ```

44. 查询和“李军”同性别并同班的同学Sname.

    ```sql
    SELECT s1.sname From students s1 JOIN students s2 On (s1.ssex = s2.ssex And s1.class = s2.class) WHERE s2.sname = '李军' And s1.sname != '李军';
    ```

45. 查询所有选修“计算机导论”课程的“男”同学的成绩表。

    ```sql
    SELECT sc.* FROM scores sc JOIN students st On st.sno = sc.sno JOIN courses c On c.cno = sc.cno WHERE c.cname = '计算机导论' And st.ssex = '男';
    
    SELECT * FROM Scores WHERE Sno IN (SELECT Sno FROM Students WHERE Ssex='男') AND Cno IN (SELECT Cno FROM Courses WHERE Cname='计算机导论');     
    ```

##### 经典练习

1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数。

   ```sql
   SELECT st.*,sc1.* FROM sc sc1  JOIN sc sc2 On (sc1.sId = sc2.sid) JOIN student st On sc1.SId = st.SId WHERE sc1.CId = '01' And  sc2.cid = '02' And sc1.score > sc2.score;
   
   select * from Student RIGHT JOIN (select t1.SId, class1, class2 from (select SId, score as class1 from sc where sc.CId = '01')as t1, (select SId, score as class2 from sc where sc.CId = '02')as t2 where t1.SId = t2.SId AND t1.class1 > t2.class2
   )r on Student.SId = r.SId;
   ```

2. 查询同时存在" 01 "课程和" 02 "课程的情况。

   ```sql
   SELECT sc1.sid FROM sc sc1 JOIN sc sc2 On sc1.sid = sc2.sid WHERE sc1.cid ='01' And sc2.CId = '02';
   
   select * from  (select * from sc where sc.CId = '01') as t1, (select * from sc where sc.CId = '02') as t2 where t1.SId = t2.SId;
   ```

3. 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )。

   ```sql
   SELECT sc1.sid,sc1.cid,sc2.cid FROM sc sc1 Left JOIN sc sc2 On (sc1.sid = sc2.sid And sc2.cid = '02') WHERE sc1.cid = '01';
   
   select * from  (select * from sc where sc.CId = '01') as t1 left join (select * from sc where sc.CId = '02') as t2 on t1.SId = t2.SId;
   ```

4. 查询不存在" 01 "课程但存在" 02 "课程的情况。

   ```sql
   select * from sc where sc.SId not in (select SId from sc where sc.CId = '01') AND sc.CId= '02';
   ```

5. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩。

   ```sql
   SELECT st.*,sum(sc.score),avg(sc.score) as avgsum From sc JOIN student st On sc.SId = st.sid GROUP BY st.SId HAVING(avgsum >= 60);
   
   select student.SId,sname,ss from student,(select SId, AVG(score) as ss from sc GROUP BY SId HAVING AVG(score)>= 60) r
   where student.sid = r.sid;
   ```

6. 查询在 SC 表存在成绩的学生信息。

     

   ```sql
   SELECT st.* From student st WHERE EXISTS (SELECT sc.SId From sc WHERE sc.SId = st.SId);
   
   SELECT st.* FROM student st WHERE st.SId in (SELECT sc.sid From sc);
   
   select DISTINCT student.* from student,sc where student.SId=sc.SId;
   ```

7. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )。

   ```sql
   SELECT st.sid,st.Sname,count(sc.sid),sum(sc.score) From student st JOIN sc On sc.SId = st.SId GROUP BY st.SId;
   
   SELECT st.sid,st.Sname,count(sc.sid),sum(sc.score) From student st Left JOIN sc On sc.SId = st.SId GROUP BY st.SId;
   
   select student.sid, student.sname,r.coursenumber,r.scoresum from student,(select sc.sid, sum(sc.score) as scoresum, count(sc.cid) as coursenumber from sc group by sc.sid)r where student.sid = r.sid;
   
   select s.sid, s.sname,r.coursenumber,r.scoresum from ((select student.sid,student.sname from student)s left join (select sc.sid, sum(sc.score) as scoresum, count(sc.cid) as coursenumber from sc group by sc.sid)r on s.sid = r.sid);
   
   ```

8. 查有成绩的学生信息。

   ```sql
   SELECT st.* From student st WHERE EXISTS (SELECT sc.SId From sc WHERE sc.SId = st.SId);
   
   SELECT st.* From student st WHERE st.SId in (SELECT sc.sid From sc);
   ```

9. 查询「李」姓老师的数量。

   ```sql
   SELECT COUNT(TId) FROM teacher WHERE Tname like '李%';
   
   SELECT COUNT(*) FROM teacher WHERE Tname like '李%';//自动最优
   ```

10. 查询学过「张三」老师授课的同学的信息。

   ```sql
   SELECT st.* From student st JOIN sc On sc.SId = st.SId JOIN course On course.CId = sc.CId JOIN teacher On teacher.TId = course.TId WHERE teacher.Tname = '张三'; 
      
   select student.* from student,teacher,course,sc where student.sid = sc.sid and course.cid=sc.cid and course.tid = teacher.tid and tname = '张三';
   ```

11. 查询没有学全所有课程的同学的信息。

    ```sql
    select * from student where student.sid not in (select sc.sid from sc group by sc.sid having count(sc.cid)= (select count(cid) from course));
    
    SELECT st.* From student st Left Join sc On sc.SId = st.SId GROUP BY st.SId HAVING count(sc.SId) < (SELECT COUNT(cid) FROM course);
    ```

12. 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息。

    ```sql
    select * from student where student.sid in (select sc.sid from sc where sc.cid in(select sc.cid from sc where sc.sid = '01'));
    
    SELECT DISTINCT st.* From sc JOIN student st On st.SId = sc.SId Join course On course.CId = sc.CId WHERE course.CId in 
    (SELECt course.cid From sc JOIN student st On st.SId = sc.SId JOIN course On course.CId = sc.CId WHERE st.SId = '01') And st.SId != '01' ;
    ```

13. 查询和" 01 "号的同学学习的课程   完全相同的其他同学的信息。

    ```sql
    SELECT st.* From sc JOIN course On course.CId = sc.CId JOIN student st On st.SId = sc.SId GROUP BY st.sid HAVING count(course.cid) = 
    (SELECT count(course.cid) From sc JOIN course On course.CId = sc.CId WHERE sc.SId = '01');
    ```

14. 查询没学过"张三"老师讲授的任一门课程的学生姓名。

    ```sql
    SELECT st.* From student st,teacher,course,sc WHERE st.SId = sc.SId And course.CId = sc.CId And course.TId = teacher.TId And teacher.Tname = '张三';//多表联合查询
    
    select * from student where student.sid not in(select sc.sid from sc,course,teacher where sc.cid = course.cid and course.tid = teacher.tid and teacher.tname= "张三");
    ```

15. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩。

    ```sql
    SELECT st.SId,st.sname,avg(sc.score) From sc JOIN student st On sc.SId = st.SId WHERE sc.score < 60 GROUP BY sc.SId HAVING COUNT(sc.SId) >= 2;
    ```

16. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息。

    ```sql
    SELECT student.* From sc,student WHERE sc.SId = student.SId  And sc.CId = '01' And sc.score < 60 ORDER BY sc.score DESC;
    ```

17. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩。

    ```sql
    SELECT * From sc LEFT JOIN (SELECT sid,avg(score) as avgScore From sc GROUP BY sid)r On r.sid = sc.SId ORDER BY r.avgScore Desc; 
    ```

18. 查询各科成绩最高分、最低分和平均分：以如下形式显示：

    以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率

    及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90

    要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

    ```sql
    SELECT sc.cid,course.cname,MAX(sc.score) as 最高分,min(sc.score) as 最低分,avg(sc.score) as 平均分,count(sc.SId) as 选修人数,
    sum(case when sc.score>=60 then 1 else 0 end )/count(*)as 及格率,
    sum(case when sc.score>=70 and sc.score<80 then 1 else 0 end )/count(*)as 中等率,
    sum(case when sc.score>=80 and sc.score<90 then 1 else 0 end )/count(*)as 优良率,
    sum(case when sc.score>=90 then 1 else 0 end )/count(*)as 优秀率,
    sum(case when sc.score = 100 THEN 1 else 0 end)/count(*) as 满分率
    From sc,course WHERE course.CId = sc.CId GROUP BY sc.CId ORDER BY count(*)DESC, sc.CId ASC;
    ```

19. 按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺。

    ```Sql
    SELECT sc1.CId,sc1.SId,sc1.score From sc sc1 GROUP BY sc1.CId,sc1.SId,sc1.score ORDER BY sc1.CId;
    
    SELECT sc1.CId,sc1.SId,sc1.score,COUNT(sc2.score)+1 as rank From sc sc1 LEFT JOIN sc sc2 On (sc1.CId = sc2.CId And sc1.score < sc2.score)GROUP BY sc1.CId,sc1.SId,sc1.score ORDER BY sc1.CId,rank ASC;
    ```

20. 按各科成绩进行排序，并显示排名， Score 重复时合并名次。

    ```Sql
    SELECT sc1.CId,sc1.SId,sc1.score,COUNT(DISTINCT sc2.score)+1 as rank From sc sc1 LEFT JOIN sc sc2 On (sc1.CId = sc2.CId And sc1.score < sc2.score)GROUP BY sc1.CId,sc1.SId,sc1.score ORDER BY sc1.CId,rank ASC;
    ```

21. 查询学生的总成绩，并进行排名，总分重复时保留名次空缺。

    ```sql
    set @crank=0;
    select q.sid, total, @crank := @crank +1 as rank from(
    select sc.sid, sum(sc.score) as total from sc
    group by sc.sid
    order by total desc)q;
    ```

22. 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺。

23. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比。

    ```sql
    select course.cname, course.cid,
    sum(case when sc.score<=100 and sc.score>85 then 1 else 0 end) as "[100-85]",
    sum(case when sc.score<=85 and sc.score>70 then 1 else 0 end) as "[85-70]",
    sum(case when sc.score<=70 and sc.score>60 then 1 else 0 end) as "[70-60]",
    sum(case when sc.score<=60 and sc.score>0 then 1 else 0 end) as "[60-0]"
    from sc left join course
    on sc.cid = course.cid
    group by sc.cid;
    ```

24. 查询各科成绩前三名的记录。

    ```sql
    select * from sc where (select count(*) from sc as a where sc.cid = a.cid and sc.score<a.score)< 3 order by cid asc, sc.score desc;//比自己分数大的记录
    
    select a.sid,a.cid,a.score from sc a left join sc b on (a.cid = b.cid and a.score<b.score) group by a.cid,a.sid having count(b.cid)<3 order by a.cid ASC,a.score DESC;//自交查询比自身大的
    ```

25. 查询每门课程被选修的学生数。

    ```sql
    SELECT course.*,COUNT(sc.SId)  From course JOIN sc On sc.CId = course.CId GROUP BY sc.CId;
    
    select cid, count(sid) from sc group by cid;
    ```

26. 查询出只选修两门课程的学生学号和姓名。

    ```sql
    SELECT st.* From student st JOIN sc On sc.SId = st.SId GROUP BY sc.SId HAVING(COUNT(sc.CId) = 2);
    
    select student.sid, student.sname from student where student.sid in(select sc.sid from sc group by sc.sid having count(sc.cid)=2);
    ```

27. 查询男生、女生人数。

    ```sql
    SELECT COUNT(SId),(case WHEN Ssex = '男' THEN '男生' else '女生' end) as 性别 From student GROUP BY Ssex;
    ```

28. 查询名字中含有「风」字的学生信息。

    ```sql
    SELECT * From student WHERE Sname like '%风%';
    ```

29. 查询同名同性学生名单，并统计同名人数。

    ```sql
    SELECT COUNT(st1.SId) as st1Count,st1.* From student st1 LEFT JOIN student st2 On (st1.Sname = st2.Sname And st1.Ssex = st2.Ssex )  GROUP BY st1.SId HAVING st1Count > 1;
    
    select * from student where sname in (select sname from student group by sname having count(*)>1);
    ```

30. 查询 1990 年出生的学生名单。

    ```sql
    SELECT * From student WHERE YEAR(Sage) = 1990;
    ```

31. 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列。

    ```sql
    SELECT course.*,avg(sc.score) as avgScore From course JOIN sc On sc.CId = course.CId GROUP BY sc.CId ORDER BY avgScore DESC,course.CId ASC;
    
    SELECT course.*,avg(sc.score) as avgScore From course,sc WHERE sc.CId = course.CId GROUP BY sc.CId ORDER BY avgScore DESC,course.CId ASC;
    ```

32. 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩。

    ```sql
    SELECT st.*,AVG(sc.score) as avgScore From student st,sc WHERE st.SId	= sc.SId GROUP BY st.SId HAVING avgScore > 85; 
    ```

33. 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数。

    ```sql
    SELECT  student.* From student,sc,course WHERE sc.CId = course.CId And student.SId	= sc.SId And course.Cname ='数学' And sc.score < 60;
    ```

34. 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）。

    ```sql
    select student.sname, cid, score from student left join sc on student.sid = sc.sid;
    ```

35. 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数。

    ```sql
    SELECT student.Sname,course.Cname,sc.score From sc,student,course WHERE sc.SId = student.SId And sc.CId = course.CId And sc.score > 70;
    ```

36. 查询存在不及格的课程 

    ```sql
    SELECT * From course WHERE cid in (SELECT sc.cid From sc WHERE sc.CId = CId And sc.score < 60); 
    
    SELECT * From course WHERE EXISTS (SELECT sc.* From sc WHERE sc.CId = course.CId And sc.score < 60); 
    
    SELECT sc.cid From sc WHERE sc.CId = CId And sc.score < 60 ;
    ```

37. 查询课程编号为 01 且课程成绩在 80 分及以上的学生的学号和姓名 。

    ```sql
    SELECT student.* From student,sc WHERE student.SId = sc.SId  And sc.CId = '01' And sc.score >= 80;
    ```

38. 求每门课程的学生人数。

    ```sql
    select sc.CId,count(*) as 学生人数 from sc GROUP BY sc.CId;
    ```

39. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩。

    ```sql
    select student.*, sc.score, sc.cid from student, teacher, course,sc where teacher.tid = course.tid and sc.sid = student.sid and sc.cid = course.cid and teacher.tname = "张三" having max(sc.score);
    
    select student.*, sc.score, sc.cid from student, teacher, course,sc where teacher.tid = course.tid and sc.sid = student.sid and sc.cid = course.cid and teacher.tname = "张三" order by score desc limit 1;
    ```

40. 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩。

    ```sql
    select student.*, sc.score, sc.cid from student, teacher, course,sc 
    where teacher.tid = course.tid
    and sc.sid = student.sid
    and sc.cid = course.cid
    and teacher.tname = "张三"
    and sc.score = (
        select Max(sc.score) 
        from sc,student, teacher, course
        where teacher.tid = course.tid
        and sc.sid = student.sid
        and sc.cid = course.cid
        and teacher.tname = "张三"
    );
    ```

41. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩。

    ```sql
    SELECT sc1.* From sc sc1 WHERE sc1.score =All (SELECT sc2.score From sc sc2 WHERE sc2.Sid = sc1.SId And sc1.CId != sc2.cid);
    
    select a.cid, a.sid,a.score from sc as a join sc as b on a.sid = b.sid and a.cid != b.cid and a.score = b.score group by cid, sid;
    ```

42. 查询每门功成绩最好的前两名。

    ```sql
    select a.sid,a.cid,a.score from sc as a left join sc as b on a.cid = b.cid and a.score<b.score group by a.cid, a.sid having count(b.cid)<2 order by a.cid;
    ```

43. 统计每门课程的学生选修人数（超过 5 人的课程才统计）。

    ```sql
    SELECT  count(sid) as c,sc.CId From sc GROUP BY CId HAVING c >= 5; 
    ```

44. 检索至少选修两门课程的学生学号。

    ```sql
    SELECT sid,count(cid) From sc GROUP BY SId HAVING count(cid) >= 2;
    ```

45. 查询选修了全部课程的学生信息。

    ```sql
    select student.* from sc ,student where sc.SId=student.SId GROUP BY sc.SId HAVING count(*) = (select DISTINCT count(*) from course);//括号很重要
    ```

46. 查询各学生的年龄，只按年份来算。

    ```sql
    SELECT  student.*,YEAR(NOW()) - YEAR(Sage) as age From student; 
    ```

47. 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一。

    ```sql
    select student.SId as 学生编号,student.Sname  as  学生姓名,TIMESTAMPDIFF(YEAR,student.Sage,CURDATE()) as 学生年龄from student;
    ```

48. 查询本周过生日的学生。

    ```sql
    select * from student where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(CURDATE());
    ```

49. 查询下周过生日的学生。

    ```sql
    select * from student where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(CURDATE())+1;
    ```

50. 查询本月过生日的学生。

    ```sql
    select * from student where MONTH(student.Sage)=MONTH(CURDATE())+1;
    ```

51. 查询下月过生日的学生。

    ```sql
    select * from student where MONTH(student.Sage)=MONTH(CURDATE())+1;
    ```

    

###### Count

- count(1)是聚索引 
- *count(),自动会优化指定到那一个字段 ，用count(),sql会帮你完成优化的*  
- count(*)将返回表格中所有存在的行的总数**包括值为null的行**
- count(列名)将返回表格中除去n**ull以外**的所有行的总数(有默认值的列也会被计入） 

###### Where、Having

- WHERE语句在GROUP BY语句之前；SQL会在分组之前计算WHERE语句。 
- HAVING语句在GROUP BY语句之后；SQL会在分组之后计算HAVING语句。 

###### All、Any、Some(<> 等同于!=)

- .. >ALL 父查询中的结果集大于子查询中每一个结果集中的值,则为真
- .. >ANY,SOME 父查询中的结果集大于子查询中任意一个结果集中的值,则为真
- .. =ANY 与子查询IN相同
- .. <>ANY OR作用，父查询中的结果集不等于子查询中的a或者b或者c,则为真
- .. NOT IN AND作用，父查询中的结果集不等于子查询中任意一个结果集中的值,则为真

###### In、Not In、Exists、Not Exists

- In的时候，会把子句中的查询作为结果缓存下来，然后对主查询中的每个记录进行查询。

- Exists的时候，不在对子查询的结果进行缓存，子查询的返回的结果并不重要。使用exists的时候，我们使先对主查询进行查询，然后根据子查询的结果是否为真来决定是否返回。 

- 子查询表大的用Exists，子查询表小的用In。 

  ```sql
  SELECT  * From rel WHERE rel.id NOT IN (SELECT rel_id FROM item );
  SELECT  * From rel WHERE NOT EXISTS (SELECT item.id From item WHERE item.rel_id = rel.id);
  ```

###### UNION、UNION ALL

- UNION 操作符用于合并两个或多个 SELECT 语句的结果集。 
- UNION 内部的 SELECT 语句必须拥有相同数量的列。列也必须拥有相似的数据类型。同时，每条 SELECT 语句中的列的顺序必须相同。 
- **默认地，UNION 操作符选取不同的值。如果允许重复的值，请使用 UNION ALL**。 
- UNION 结果集中的列名总是等于 UNION 中第一个 SELECT 语句中的列名。 

###### Like

- 'A_Z': 所有以 'A' 起头，另一个任何值的字原，且以 'Z' 为结尾的字串。 'ABZ' 和 'A2Z' 都符合这一个模式，而 'AKKZ' 并不符合 (因为在 A 和 Z 之间有两个字原，而不是一个字原)。
- 'ABC%': 所有以 'ABC' 起头的字串。举例来说，'ABCD' 和 'ABCABC' 都符合这个套式。
- '%XYZ': 所有以 'XYZ' 结尾的字串。举例来说，'WXYZ' 和 'ZZXYZ' 都符合这个套式。
- '%AN%': 所有含有 'AN' 这个套式的字串。举例来说， 'LOS ANGELES' 和 'SAN FRANCISCO' 都符合这个套式。

###### TIMESTAMPDIFF 、TIMESTAMPADD 

- TIMESTAMPDIFF(interval,datetime_expr1,datetime_expr2) ：返回日期或日期时间表达式datetime_expr1 和datetime_expr2the 之间的整数差。其结果的单位由interval 参数给出。该参数必须是以下值的其中一个 。
- TIMESTAMPADD(interval,int_expr,datetime_expr) ：将整型表达式int_expr 添加到日期或日期时间表达式 datetime_expr中。式中的interval和上文中列举的取值是一样的。 
- 参数
  - FRAC_SECOND。表示间隔是毫秒
  - SECOND。秒
  - MINUTE。分钟
  - HOUR。小时
  - DAY。天
  - WEEK。星期
  - MONTH。月
  - QUARTER。季度
  - YEAR。年

###### 变量

- SQL里面变量用@来标识 。



- group by以后的查询结果无法使用别名。
- CURDATE() 函数返回当前的日期。 
- WEEKOFYEAR() 返回日期用数字表示的范围是从1到53的日历周。WEEKOFYEAR()是一个兼容性函数，它等效于WEEK(date,3)。 

