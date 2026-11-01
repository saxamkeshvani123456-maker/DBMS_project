import 'dotenv/config';
import oracledb from 'oracledb';

oracledb.outFormat=oracledb.OUT_FORMAT_OBJECT;oracledb.fetchAsString=[oracledb.CLOB];
let pool;
export async function getPool(){if(!pool)pool=await oracledb.createPool({user:process.env.ORACLE_USER,password:process.env.ORACLE_PASSWORD,connectString:process.env.ORACLE_CONNECT_STRING,poolMin:Number(process.env.ORACLE_POOL_MIN||1),poolMax:Number(process.env.ORACLE_POOL_MAX||8),poolIncrement:1});return pool;}
export async function query(sql,binds={},opts={}){const{commit=false,clientIdentifier,...executeOptions}=opts;const c=await(await getPool()).getConnection();try{await c.execute('BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;');if(clientIdentifier)await c.execute('BEGIN DBMS_SESSION.SET_IDENTIFIER(:id); END;',{id:String(clientIdentifier).slice(0,64)});const result=await c.execute(sql,binds,{outFormat:oracledb.OUT_FORMAT_OBJECT,autoCommit:false,...executeOptions});if(commit)await c.commit();return result;}catch(e){await c.rollback();throw e;}finally{await c.close();}}
export async function closePool(){if(pool){await pool.close(10);pool=undefined;}}
export {oracledb};
