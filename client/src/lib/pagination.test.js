import{describe,it,expect}from'vitest';import{pageWindow}from'./pagination';
describe('pageWindow',()=>{it('uses deterministic 1-based bounds',()=>expect(pageWindow(2,10)).toEqual({page:2,pageSize:10,firstRow:11,lastRow:20}));it('clamps invalid values and page size',()=>expect(pageWindow(0,100)).toEqual({page:1,pageSize:50,firstRow:1,lastRow:50}))});
