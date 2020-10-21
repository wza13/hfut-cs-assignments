import random

Class_header = ['ClsNO', 'ClsName', 'Director', 'Specialty']
Class = [['CS01', '计算机一班', '张宁', '计算机应用'],
         ['CS02', '计算机二班', '王宁', '计算机应用'],
         ['MT04', '数学四班', '陈晨', '数学'],
         ['PH08', '物理八班', '葛格', '物理'],
         ['GL01', '地理一班', '张四', '应用地理']]

Student_header = ['Sno', 'Sname', 'Ssex', 'ClsNO', 'Saddr', 'Sage', 'Height']
Student = [['20170101', '王军', '男', 'CS01', '下关40#', 20, 1.76],
           ['20170102', '李杰', '男', 'CS01', '江边路96#', 22, 1.72],
           ['20170306', '王彤', '女', 'MT04', '中央路94#', 19, 1.65],
           ['20170107', '吴杪', '女', 'PH08', '莲化小区74#', 18, 1.60]]

Course_header = ['Cno', 'CName', 'Cpno', 'Credit']
Course = [['0001', '高等数学', 'Null', 6],
          ['0003', '计算机基础', '0001', 3],
          ['0007', '物理', '0001', 4]]

SC_header = ['SNO', 'CNO', 'Grade']
SC = [['20170101', '0001', 90],
      ['20170101', '0007', 86],
      ['20170102', '0001', 87],
      ['20170102', '0003', 76],
      ['20170306', '0001', 87],
      ['20170306', '0003', 93],
      ['20170107', '0007', 85],
      ['20170306', '0007', 90]]


stu_ids = []
for i in range(40):
    stu_id = str(random.randint(2016, 2020)) + '0' + str(random.randint(100, 999))
    stu_ids.append(stu_id)

    stu_name = random.choice(['王', '李', '吴', '葛', '陈', '张', '余', '钱']) \
                + random.choice(['一', '二', '三', '四', '五', '六', '七', '八', '九'])
    stu_sex = random.choice(['男', '女'])
    stu_cls = random.choice(['CS01', 'CS02', 'MT04', 'PH08', 'GL01'])
    stu_addr = 'Null'
    stu_age = random.randint(18, 24)
    # stu_height = '%.2f' % ((random.randint(150, 200)) / 100.0)
    stu_height = (random.randint(150, 200)) / 100.0
    Student.append([stu_id, stu_name, stu_sex, stu_cls, stu_addr, stu_age, stu_height])


course_ids = ['0001', '0003', '0007']
cp_ids = ['Null'] + course_ids
for i in range(10):
    course_id = str(random.randint(1000, 9999))
    course_ids.append(str(course_id))
    course_name = ''.join(random.choices(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'], k=5))
    cp_id = random.choice(cp_ids)
    course_credit = random.randint(1, 6)
    Course.append([course_id, course_name, cp_id, course_credit])


for i in range(100):
    new_sc = []
    while True:
        dup = 0
        new_sc = [random.choice(stu_ids), random.choice(course_ids), random.randint(60, 99)]
        for sc in SC:
            if new_sc[0] == sc[0] and new_sc[1] == sc[1]:
                dup = 1
                break
        if dup == 0:
            break
    SC.append(new_sc)


def list_to_sql(lst):
    sql = str(lst)
    sql = sql.replace('[', '(')
    sql = sql.replace(']', ')')
    sql = sql.replace("'Null'", "Null")
    return sql


with open('lab3_insert.sql', 'w', encoding='utf-8') as f:
    f.truncate()
    f.write('USE EDUC;\n')
    f.write('DELETE FROM SC;\n')
    f.write('DELETE FROM Course;\n')
    f.write('DELETE FROM Student;\n')
    f.write('DELETE FROM Class;\n\n')

    f.write('INSERT INTO Class VALUES\n')
    for i in Class:
        if i == Class[-1]:
            f.write('    ' + list_to_sql(i) + ';\n')
        else:
            f.write('    ' + list_to_sql(i) + ',\n')
    f.write('\n')

    f.write('INSERT INTO Student VALUES\n')
    for i in Student:
        if i == Student[-1]:
            f.write('    ' + list_to_sql(i) + ';\n')
        else:
            f.write('    ' + list_to_sql(i) + ',\n')
    f.write('\n')

    f.write('INSERT INTO Course VALUES\n')
    for i in Course:
        if i == Course[-1]:
            f.write('    ' + list_to_sql(i) + ';\n')
        else:
            f.write('    ' + list_to_sql(i) + ',\n')
    f.write('\n')

    f.write('INSERT INTO SC VALUES\n')
    for i in SC:
        if i == SC[-1]:
            f.write('    ' + list_to_sql(i) + ';\n')
        else:
            f.write('    ' + list_to_sql(i) + ',\n')
