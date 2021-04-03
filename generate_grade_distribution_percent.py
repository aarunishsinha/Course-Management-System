#only used for generating some query in students.py
# x=['a_count','ab_count','b_count','bc_count','c_count','d_count','f_count','s_count','u_count','cr_count','n_count','p_count','i_count','nw_count','nr_count','other_count']
# for i in x:
# 	print('(cast ('+i+' as float)/t.total*100)::numeric(10,2) as '+i+'_p,')

#used for clash
# x=['mon','tues','wed','thurs','fri','sat', 'sun']
x=['start_time','end_time' ,'mon','tues','wed','thurs','fri','sat', 'sun']
# x=[,end_time,mon,tues,wed,thurs,fri,sat,sun]
for i in x:
	print(i+' as '+i+'_c,', end="")
	# print('('+i+' and '+i+'_c) or ', end="")