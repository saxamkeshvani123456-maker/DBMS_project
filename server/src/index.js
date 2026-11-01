import express from'express';import cors from'cors';import helmet from'helmet';import rateLimit from'express-rate-limit';import'dotenv/config';
import auth from'./routes/auth.js';import campus from'./routes/campus.js';import lab from'./routes/lab.js';import{closePool}from'./db.js';import{fileURLToPath}from'node:url';
const app=express();app.use(helmet());app.use(cors({origin:process.env.CLIENT_ORIGIN||'http://localhost:5173'}));app.use(express.json({limit:'1mb'}));
app.use('/api/auth',rateLimit({windowMs:15*60*1000,limit:80}),auth);app.use('/api/lab',lab);app.use('/api',campus);
app.get('/api/health',(_req,res)=>res.json({status:'ok',service:'CampusConnect API'}));
app.use((err,_req,res,_next)=>{console.error(err);if(err.errorNum===1)return res.status(409).json({error:'A record with this unique value already exists'});if(err.errorNum===2291)return res.status(400).json({error:'A related record does not exist'});if(err.errorNum===2292)return res.status(409).json({error:'Related records preserve this history'});if(err.errorNum>=20000&&err.errorNum<=20999)return res.status(400).json({error:String(err.message).replace(/^ORA-\d+:\s*/,'').split('\n')[0]});res.status(500).json({error:process.env.NODE_ENV==='production'?'Request could not be completed':err.message});});
if(process.argv[1]&&fileURLToPath(import.meta.url)===process.argv[1]){const port=Number(process.env.PORT||4000);app.listen(port,()=>console.log(`CampusConnect API listening on ${port}`));}
process.on('SIGINT',async()=>{await closePool();process.exit(0)});export default app;
