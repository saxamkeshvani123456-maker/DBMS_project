$ErrorActionPreference = 'Stop'
$out = Join-Path (Get-Location) 'presentation_output/CampusConnect_Project_Overview.pptx'
$preview = Join-Path (Get-Location) '.presentation-build/previews'
New-Item -ItemType Directory -Force -Path $preview | Out-Null

function Color([string]$hex) {
  $r=[Convert]::ToInt32($hex.Substring(0,2),16); $g=[Convert]::ToInt32($hex.Substring(2,2),16); $b=[Convert]::ToInt32($hex.Substring(4,2),16)
  return [int]($r + 256*$g + 65536*$b)
}
function Rect($s,[double]$x,[double]$y,[double]$w,[double]$h,[string]$fill,[string]$line='FFFFFF',[double]$lineW=0) {
  $shape=$s.Shapes.AddShape(1,$x,$y,$w,$h); $shape.Fill.Solid(); $shape.Fill.ForeColor.RGB=Color $fill
  if($lineW -le 0){$shape.Line.Visible=0}else{$shape.Line.Visible=-1;$shape.Line.ForeColor.RGB=Color $line;$shape.Line.Weight=$lineW}
}
function Txt($s,[string]$text,[double]$x,[double]$y,[double]$w,[double]$h,[double]$size,[string]$color,[bool]$bold=$false,[int]$align=1) {
  $shape=$s.Shapes.AddTextbox(1,$x,$y,$w,$h); $shape.Fill.Visible=0; $shape.Line.Visible=0
  $tf=$shape.TextFrame; $tf.MarginLeft=0; $tf.MarginRight=0; $tf.MarginTop=0; $tf.MarginBottom=0; $tf.WordWrap=-1; $tf.AutoSize=0
  $text=$text.Replace('\n',[Environment]::NewLine)
  $tr=$tf.TextRange; $tr.Text=$text; $tr.Font.Name='Aptos'; $tr.Font.Size=$size; $tr.Font.Bold=$bold; $tr.Font.Color.RGB=Color $color
  $tr.ParagraphFormat.Alignment=$align; $tr.ParagraphFormat.SpaceAfter=3
}
function Line($s,[double]$x1,[double]$y1,[double]$x2,[double]$y2,[string]$color='9AABBA',[double]$weight=1.5) {
  $ln=$s.Shapes.AddLine($x1,$y1,$x2,$y2); $ln.Line.ForeColor.RGB=Color $color; $ln.Line.Weight=$weight
}
function Header($s,[string]$title,[int]$num) {
  $s.FollowMasterBackground=0; $s.Background.Fill.ForeColor.RGB=Color 'F6F8FB'
  Rect $s 0 0 10 540 '159E9A'
  Txt $s $title 48 28 820 45 29 '17324D' $true
  Line $s 48 84 912 84 'D9E3EC' 1
  Line $s 48 510 912 510 'D9E3EC' 0.8
  Txt $s 'CampusConnect   -   SVNIT CS203 DBMS' 48 517 500 16 9.5 '718396' $false
  Txt $s ('2026 - 27   -   ' + $num) 830 517 82 16 9.5 '718396' $false 3
}
function Entity($s,[string]$name,[string]$detail,[double]$x,[double]$y,[double]$w=218,[double]$h=86) {
  Rect $s $x $y $w $h 'FFFFFF' 'B8C9D8' 1.2
  Rect $s $x $y 5 $h '159E9A'
  Txt $s $name ($x+15) ($y+10) ($w-25) 24 15.5 '17324D' $true
  Txt $s $detail ($x+15) ($y+38) ($w-24) ($h-43) 11.5 '536A7E' $false
}

$pp=New-Object -ComObject PowerPoint.Application
$pp.Visible=-1
$pres=$pp.Presentations.Add()
$pres.PageSetup.SlideSize=16
$pres.PageSetup.SlideWidth=960
$pres.PageSetup.SlideHeight=540

# 1  -  Cover
$s=$pres.Slides.Add(1,12); $s.FollowMasterBackground=0; $s.Background.Fill.ForeColor.RGB=Color '17324D'
Rect $s 70 115 5 295 '28B3A7'
Txt $s 'CampusConnect' 104 142 630 66 45 'FFFFFF' $true
Txt $s 'SVNIT Surat  |  CS203 Database Management Systems' 106 220 690 34 20 'D6E5F0' $false
Txt $s 'A relational campus portal built on Oracle SQL and PL/SQL' 106 302 610 54 22 'FFFFFF' $false
Txt $s 'Project overview   -   Academic Year 2026 - 27' 106 406 570 25 14 '8FB4C8' $false
Line $s 104 458 890 458 '35536D' 1
Txt $s 'STUDENTS   -   CLUBS   -   EVENTS   -   CAMPUS SERVICES' 106 475 680 22 11 'AFC8D8' $true
# restrained editable relationship motif
Line $s 760 178 835 255 '2B7784' 2; Line $s 835 255 760 332 '2B7784' 2; Line $s 760 178 760 332 '2B7784' 2
foreach($pt in @(@(748,166),@(823,243),@(748,320))){$sh=$s.Shapes.AddShape(9,$pt[0],$pt[1],24,24);$sh.Fill.ForeColor.RGB=Color '28B3A7';$sh.Line.Visible=0}

# 2  -  Purpose and scope
$s=$pres.Slides.Add(2,12); Header $s 'Project purpose and scope' 2
Txt $s 'The problem' 54 112 360 28 18 '159E9A' $true
Txt $s 'Campus information is scattered across informal channels. Students need one reliable place to discover activities, share resources and report lost items.' 54 151 380 125 19 '17324D' $false
Txt $s 'Project goals' 54 302 360 28 18 '159E9A' $true
Txt $s ' -  Keep campus records consistent with relational constraints\n -  Provide role-aware workflows for students, coordinators and administrators\n -  Demonstrate Oracle SQL and PL/SQL through a safe DBMS Lab' 54 339 410 130 16.5 '536A7E' $false
Line $s 484 118 484 468 'D9E3EC' 1
Txt $s 'One integrated portal' 523 112 380 28 18 '159E9A' $true
Txt $s 'Community' 523 158 150 24 16.5 '17324D' $true
Txt $s 'Clubs, membership, events, registrations and announcements' 674 158 245 45 16 '536A7E' $false
Txt $s 'Campus services' 523 230 150 24 16.5 '17324D' $true
Txt $s 'Lost-and-found listings and academic resources' 674 230 245 45 16 '536A7E' $false
Txt $s 'Administration' 523 302 150 24 16.5 '17324D' $true
Txt $s 'Club request review, user roles and database-driven statistics' 674 302 245 50 16 '536A7E' $false
Txt $s 'DBMS Lab' 523 384 150 24 16.5 '17324D' $true
Txt $s 'Allowlisted CRUD, queries, XML output, views, procedures and benchmarks' 674 384 245 60 16 '536A7E' $false

# 3  -  Architecture
$s=$pres.Slides.Add(3,12); Header $s 'Application architecture' 3
$xs=@(46,274,502,730); $titles=@('Browser','Express API','Node Oracle driver','Oracle database'); $body=@('React + Vite\nRouter  -  Axios\nResponsive portal','JWT + bcrypt\nRole checks\nValidation + allowlists','node-oracledb\nBind variables\nConnection pool','CAMPUSCONNECT\n11 relational tables\nViews  -  PL/SQL  -  triggers')
for($i=0;$i -lt 4;$i++){
  Rect $s $xs[$i] 172 182 182 'FFFFFF' 'C7D5E0' 1
  Rect $s $xs[$i] 172 182 7 '159E9A'
  Txt $s $titles[$i] ($xs[$i]+16) 196 150 28 17 '17324D' $true
  Txt $s $body[$i] ($xs[$i]+16) 245 150 90 15.5 '536A7E' $false
  if($i -lt 3){Line $s ($xs[$i]+187) 263 ($xs[$i+1]-9) 263 '159E9A' 2;Txt $s ' - ' ($xs[$i+1]-15) 246 20 28 23 '159E9A' $true}
}
Txt $s 'The browser sends JSON to Express. Only the backend holds Oracle credentials and issues parameterized database calls.' 75 390 810 56 19 '17324D' $false 2
Txt $s 'Authentication and role enforcement happen on the server; the frontend cannot submit arbitrary SQL.' 104 455 752 30 15 '63788A' $false 2

# 4  -  ER relationship model
$s=$pres.Slides.Add(4,12); Header $s 'ER relationship model' 4
# connectors first so entity boxes sit above them
Line $s 263 183 366 183 '879BAE' 1.6; Txt $s '1 : many' 283 159 74 17 11 '536A7E' $true 2
Line $s 593 183 697 183 '879BAE' 1.6; Txt $s 'many : 1' 604 159 79 17 11 '536A7E' $true 2
Line $s 806 230 806 329 '879BAE' 1.6; Txt $s '1 : many' 815 270 70 17 11 '536A7E' $true
Line $s 697 372 593 372 '879BAE' 1.6; Txt $s '1 : many' 606 348 77 17 11 '536A7E' $true 2
Line $s 160 230 160 329 '879BAE' 1.6; Txt $s '1 : many' 169 270 72 17 11 '536A7E' $true
Line $s 263 218 366 343 '879BAE' 1.4; Txt $s '1 : many' 283 276 78 17 11 '536A7E' $true
Entity $s 'USERS' 'PK user_id   -   email UQ' 45 140 218 90
Entity $s 'CLUB_MEMBERSHIPS' 'PK membership_id   -   user_id FK   -   club_id FK   -   pair UQ' 366 140 227 90
Entity $s 'CLUBS' 'PK club_id   -   club_name UQ' 697 140 218 90
Entity $s 'ANNOUNCEMENTS' 'PK announcement_id   -   author FK   -   nullable club_id' 45 329 218 86
Entity $s 'EVENT_REGISTRATIONS' 'PK registration_id   -   user_id FK   -   event_id FK   -   pair UQ' 366 329 227 86
Entity $s 'EVENTS' 'PK event_id   -   club_id FK   -   created_by FK' 697 329 218 86
Txt $s 'CLUB_MEMBERSHIPS resolves Users  -  Clubs (M:N).  EVENT_REGISTRATIONS resolves Users  -  Events (M:N).' 57 434 846 22 14 '17324D' $true 2
Txt $s 'One user authors many announcements; club_id is optional, so NULL means campus-wide.' 82 462 800 20 13.5 '63788A' $false 2

# 5  -  Relational schema and key attributes
$s=$pres.Slides.Add(5,12); Header $s 'Relational schema and key attributes' 5
Txt $s 'PK primary key    -    FK foreign key    -    UQ unique constraint' 51 99 850 19 13.5 '63788A' $false
$cols=@(48,350,652); $groups=@(
  @(@('USERS','PK user_id; full_name; email UQ; password_hash; enrollment_number UQ; department; year; role'),@('CLUBS','PK club_id; club_name UQ; description; category; logo_url; created_at'),@('CLUB_MEMBERSHIPS','PK membership_id; user_id FK; club_id FK; role; status; joined_at; UQ(user_id, club_id)'),@('CLUB_REQUESTS','PK request_id; requested_by FK; reviewed_by FK; proposed_name; status; requested_at; reviewed_at')),
  @(@('EVENTS','PK event_id; club_id FK; created_by FK; title; venue; start/end; capacity; status'),@('EVENT_REGISTRATIONS','PK registration_id; event_id FK; user_id FK; status; registered_at; UQ(event_id, user_id)'),@('ANNOUNCEMENTS','PK announcement_id; created_by FK; nullable club_id; title; content; timestamps'),@('LOST_FOUND_ITEMS','PK item_id; reported_by FK; item_name; type; location; status; reported/resolved times')),
  @(@('ACADEMIC_RESOURCES','PK resource_id; uploaded_by FK; title; subject; semester; URL; uploaded_at'),@('APPLICATION_AUDIT_LOG','PK audit_id; table_name; record_id; operation; actor; time; old/new CLOB; no FK by design'),@('ACTIVITY_LOGS','PK log_id; nullable user_id FK; action; entity_type; entity_id; created_at'))
)
for($c=0;$c -lt 3;$c++){
  $y=128
  foreach($item in $groups[$c]){
    Txt $s $item[0] $cols[$c] $y 270 22 15.5 '17324D' $true
    Txt $s $item[1] $cols[$c] ($y+27) 270 54 12.8 '536A7E' $false
    Line $s $cols[$c] ($y+83) ($cols[$c]+267) ($y+83) 'D9E3EC' 0.8
    $y+=94
  }
}

# 6  -  Constraints and normalization
$s=$pres.Slides.Add(6,12); Header $s 'Integrity constraints and 3NF' 6
Txt $s 'Integrity rules' 54 111 390 30 19 '159E9A' $true
Txt $s ' -  Identity-generated numeric primary keys\n -  Unique email and enrollment number; unique club name\n -  Unique pairs prevent duplicate memberships and event registrations\n -  Foreign keys preserve valid users, clubs and events\n -  CHECK rules restrict roles, statuses, years, semesters and item types\n -  Event end > start; capacity > 0; triggers enforce future start and registration capacity' 54 154 405 286 16 '17324D' $false
Line $s 483 116 483 467 'D9E3EC' 1
Txt $s 'Normalization' 524 111 370 30 19 '159E9A' $true
Txt $s '1NF' 524 158 60 24 16.5 '17324D' $true
Txt $s 'Each column stores one value; repeated groups are separate rows.' 591 158 324 42 15.5 '536A7E' $false
Txt $s '2NF' 524 232 60 24 16.5 '17324D' $true
Txt $s 'Relationship facts depend on the whole composite key, such as (event_id, user_id).' 591 232 324 52 15.5 '536A7E' $false
Txt $s '3NF' 524 320 60 24 16.5 '17324D' $true
Txt $s 'User, club and event descriptions live in their own tables, avoiding transitive duplication.' 591 320 324 56 15.5 '536A7E' $false
Txt $s 'Examples of functional dependencies' 524 405 390 22 14 '159E9A' $true
Txt $s 'user_id determines name, email and role; event_id + user_id determine registration_status and registered_at' 524 435 390 42 13.5 '536A7E' $false

# 7  -  Oracle SQL and PL/SQL
$s=$pres.Slides.Add(7,12); Header $s 'Oracle SQL and PL/SQL demonstrations' 7
Txt $s 'SQL query lab' 54 111 390 30 19 '159E9A' $true
Txt $s ' -  Display-all and conditional queries\n -  COUNT, SUM, AVG, MIN and MAX\n -  INNER, LEFT, RIGHT and FULL OUTER JOIN\n -  Subqueries and correlated subqueries\n -  Updates, pagination and view operations\n -  XML output for Q1, Q3 and Q4 from actual rows\n -  Index comparisons use measured plans and timings' 54 153 405 280 16 '17324D' $false
Line $s 483 116 483 466 'D9E3EC' 1
Txt $s 'PL/SQL & integrity' 524 111 390 30 19 '159E9A' $true
Txt $s ' -  Separate INSERT, UPDATE and DELETE procedures\n -  Explicit cursor and BULK COLLECT ... LIMIT\n -  Aggregate functions and paginated REF CURSORs\n -  BEFORE validation and uppercase normalization triggers\n -  AFTER row trigger writes event audit records\n -  Monday 14:00 - 16:00 Asia/Kolkata event lock\n -  V_CLUB_EVENT uses an INSTEAD OF INSERT trigger' 524 153 390 285 16 '17324D' $false
Txt $s 'All interactive SQL is server-selected and parameterized; the browser cannot submit arbitrary SQL.' 95 462 770 22 14 '63788A' $false 2

# 8  -  Security, setup, and demonstration
$s=$pres.Slides.Add(8,12); Header $s 'Security, setup and project demonstration' 8
Txt $s 'Three application roles' 51 111 275 26 17 '159E9A' $true
Txt $s 'STUDENT   -   discover, join, register, contribute\nCOORDINATOR   -   manage club events and announcements\nADMIN   -   review requests and manage users' 51 151 280 105 14.5 '17324D' $false
Line $s 347 115 347 314 'D9E3EC' 1
Txt $s 'Application security' 375 111 245 26 17 '159E9A' $true
Txt $s 'bcrypt password hashes  -  JWT sessions\nBackend role checks  -  input validation\nBind variables  -  identifier allowlists\nOracle credentials stay in server/.env' 375 151 250 95 14.5 '17324D' $false
Line $s 643 115 643 314 'D9E3EC' 1
Txt $s 'Run locally' 670 111 220 26 17 '159E9A' $true
Txt $s '1 Install Oracle and configure FREEPDB1; 2 run schema scripts; 3 configure server/.env and seed; 4 npm install and npm run dev; 5 open localhost:5173' 670 151 250 110 13.5 '17324D' $false
Line $s 51 290 912 290 'D9E3EC' 1
Txt $s 'Live demo sequence' 51 310 260 26 17 '159E9A' $true
Txt $s 'Sign in, browse clubs, approve a club request, join, create and register for an event, share campus content, view live statistics, then run DBMS Lab queries and PL/SQL.' 51 350 858 62 17 '17324D' $false
Txt $s 'Local Oracle scripts and benchmark results must be executed on the configured database; no unrun database test or timing is presented as completed.' 51 437 858 42 13.5 '63788A' $false

$pres.SaveAs($out,24)
for($i=1;$i -le $pres.Slides.Count;$i++){$pres.Slides.Item($i).Export((Join-Path $preview ('slide-{0:D2}.png' -f $i)),'PNG',1280,720)}
$pres.Close(); $pp.Quit()
Write-Output "Created $out"

