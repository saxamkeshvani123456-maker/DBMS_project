import 'dotenv/config';
import bcrypt from 'bcryptjs';
import oracledb from 'oracledb';

const password=process.env.SEED_DEMO_PASSWORD||'CampusDemo!2026';
const hash=await bcrypt.hash(password,12);
const connection=await oracledb.getConnection({user:process.env.ORACLE_USER,password:process.env.ORACLE_PASSWORD,connectString:process.env.ORACLE_CONNECT_STRING});
try{
 const people=[
  ['Aarav Shah','aarav.shah@campusconnect.test','ADMIN','U25CS001'],
  ['Mira Patel','mira.patel@campusconnect.test','COORDINATOR','U25CS014'],
  ['Kabir Desai','kabir.desai@campusconnect.test','COORDINATOR','U25CS032'],
  ['Anaya Mehta','anaya.mehta@campusconnect.test','STUDENT','U25CS046'],
  ['Ishaan Joshi','ishaan.joshi@campusconnect.test','STUDENT','U25CS051']
 ];
 for(const [name,email,role,enrollment] of people) await connection.execute(`MERGE INTO USERS d USING(SELECT :p_email email FROM dual)s ON(d.email=s.email) WHEN MATCHED THEN UPDATE SET d.full_name=:p_name,d.role=:p_role,d.password_hash=:p_hash WHEN NOT MATCHED THEN INSERT(full_name,email,password_hash,enrollment_number,department,year_of_study,role) VALUES(:p_name,:p_email,:p_hash,:p_enrollment,'Computer Science and Engineering',2,:p_role)`,{p_name:name,p_email:email,p_role:role,p_enrollment:enrollment,p_hash:hash});
 const clubs=[['Robotics Society','Build, test and compete with autonomous systems.','TECH'],['CodeChef SVNIT','Programming contests, peer learning and interview preparation.','TECH'],['Euphoria','Music, performance and creative community.','CULTURAL']];
 for(const [name,description,category] of clubs) await connection.execute(`MERGE INTO CLUBS d USING(SELECT :p_club_name club_name FROM dual)s ON(UPPER(d.club_name)=UPPER(s.club_name)) WHEN MATCHED THEN UPDATE SET d.description=:p_description WHEN NOT MATCHED THEN INSERT(club_name,description,category) VALUES(:p_club_name,:p_description,:p_category)`,{p_club_name:name,p_description:description,p_category:category});
 const ids=await connection.execute(`SELECT user_id,email FROM USERS WHERE email IN ('mira.patel@campusconnect.test','kabir.desai@campusconnect.test','anaya.mehta@campusconnect.test')`,[],{outFormat:oracledb.OUT_FORMAT_OBJECT});
 const clubRows=await connection.execute(`SELECT club_id,club_name FROM CLUBS WHERE UPPER(club_name) IN ('ROBOTICS SOCIETY','CODECHEF SVNIT','EUPHORIA')`,[],{outFormat:oracledb.OUT_FORMAT_OBJECT});
 const userId=Object.fromEntries(ids.rows.map(r=>[r.EMAIL,r.USER_ID])); const clubId=Object.fromEntries(clubRows.rows.map(r=>[r.CLUB_NAME.toUpperCase(),r.CLUB_ID]));
 for(const [email,clubName,role] of [['mira.patel@campusconnect.test','Robotics Society','COORDINATOR'],['kabir.desai@campusconnect.test','CodeChef SVNIT','COORDINATOR'],['anaya.mehta@campusconnect.test','Euphoria','MEMBER']]){
  const uid=userId[email]|| (await connection.execute('SELECT user_id FROM USERS WHERE email=:p_email',{p_email:email})).rows[0].USER_ID;
  await connection.execute(`MERGE INTO CLUB_MEMBERSHIPS d USING(SELECT :p_user_id user_id,:p_club_id club_id FROM dual)s ON(d.user_id=s.user_id AND d.club_id=s.club_id) WHEN MATCHED THEN UPDATE SET d.membership_role=:p_membership_role,d.membership_status='ACTIVE' WHEN NOT MATCHED THEN INSERT(user_id,club_id,membership_role,membership_status) VALUES(:p_user_id,:p_club_id,:p_membership_role,'ACTIVE')`,{p_user_id:uid,p_club_id:clubId[clubName.toUpperCase()],p_membership_role:role});
 }
 const coord=userId['mira.patel@campusconnect.test'];
 for(const [title,club,venue,days,capacity] of [['RoboRave: Build Night','Robotics Society','Innovation Lab',12,80],['Algorithm Jam','CodeChef SVNIT','L.D. Hall',18,120],['Open Mic Under the Stars','Euphoria','Amphitheatre',25,150],['Autonomous Sprint Demo','Robotics Society','Workshop 4',32,60]])
  await connection.execute(`MERGE INTO EVENTS d USING(SELECT :p_title title,:p_club_id club_id FROM dual)s ON(d.title=s.title AND d.club_id=s.club_id) WHEN NOT MATCHED THEN INSERT(club_id,created_by,title,description,venue,start_datetime,end_datetime,capacity,event_status) VALUES(:p_club_id,:p_creator,:p_title,'A student-led campus gathering.','${venue}',SYSTIMESTAMP+NUMTODSINTERVAL(${days},'DAY'),SYSTIMESTAMP+NUMTODSINTERVAL(${days},'DAY')+INTERVAL '2' HOUR,:p_capacity,'PUBLISHED')`,{p_title:title,p_club_id:clubId[club.toUpperCase()],p_creator:coord,p_capacity:capacity});
 await connection.execute(`INSERT INTO ANNOUNCEMENTS(created_by,club_id,title,content) SELECT :p_user_id,NULL,'Welcome to CampusConnect','Explore clubs, events and learning resources shared by the SVNIT community.' FROM dual WHERE NOT EXISTS(SELECT 1 FROM ANNOUNCEMENTS WHERE title='Welcome to CampusConnect')`,{p_user_id:coord});
 await connection.execute(`INSERT INTO LOST_FOUND_ITEMS(reported_by,item_name,description,item_type,location) SELECT user_id,'Blue water bottle','Steel bottle with a white sticker.','FOUND','Central Library' FROM USERS WHERE email='kabir.desai@campusconnect.test' AND NOT EXISTS(SELECT 1 FROM LOST_FOUND_ITEMS WHERE item_name='Blue water bottle')`);
 await connection.execute(`INSERT INTO ACADEMIC_RESOURCES(uploaded_by,title,description,subject,semester,resource_url) SELECT user_id,'Oracle SQL quick reference','A curated reference for joins, grouping and constraints.','Database Systems',3,'https://docs.oracle.com/en/database/' FROM USERS WHERE email='mira.patel@campusconnect.test' AND NOT EXISTS(SELECT 1 FROM ACADEMIC_RESOURCES WHERE title='Oracle SQL quick reference')`);
 await connection.commit();
 console.log('Demo data is ready. Demo emails: aarav.shah@campusconnect.test and mira.patel@campusconnect.test. Shared local-only password:',password);
}catch(error){await connection.rollback();throw error;}finally{await connection.close();}
