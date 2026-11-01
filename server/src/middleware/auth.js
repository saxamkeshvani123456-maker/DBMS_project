import jwt from'jsonwebtoken';import'dotenv/config';
export function authenticate(req,res,next){const token=req.headers.authorization?.replace(/^Bearer\s+/i,'');if(!token)return res.status(401).json({error:'Sign in to continue'});try{req.user=jwt.verify(token,process.env.JWT_SECRET);next();}catch{return res.status(401).json({error:'Session expired. Sign in again.'});}}
export const allowRoles=(...roles)=>(req,res,next)=>roles.includes(req.user?.role)?next():res.status(403).json({error:'Your account does not have permission for this action'});
