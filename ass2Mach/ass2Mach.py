fun15_11 = {
    'ADD'   :'000_00',
    'SUB'   :'000_00',
    'MUL'   :'000_00',
    'AND'   :'000_01',
    'OR'    :'000_01',
    'XOR'   :'000_01',
    'SLL'   :'000_10',
    'SRL'   :'000_10',
    'SLLI'  :'000_11',
    'SRLI'  :'000_11',
    'ANDI'  :'001_00',
    'ORI'   :'001_01',
    'XORI'  :'001_10',
    'ADDI'  :'001_11',
    'BEQ'   :'010_00',
    'BLT'   :'010_01',
    'BNE'   :'010_10',
    'JAL'   :'011_00',
    'LD'    :'100_00',
    'SD'    :'100_01',
}

fun1_0 = {
    'ADD'   :'00',
    'SUB'   :'01',
    'MUL'   :'10',
    'AND'   :'00',
    'OR'    :'01',
    'XOR'   :'10',
    'SLL'   :'00',
    'SRL'   :'01',
    'SLLI'  :'00',
    'SRLI'  :'01',
}

def int2NegBin(num, len):
    # Two's complement
    num = -num
    inv_bit     = num ^ ((1 << len) - 1)
    neg_bin     = format(inv_bit + 1, f'0{len}b')
    return neg_bin

def int2bin(num, len):
    if not isinstance(num, int):
        num = int(num)
    if num >= 0:
        return format(num, f'0{len}b')
    return int2NegBin(num, len)

def readAssCode(s):
    s = s.upper()
    s = s.split('#')[0].strip()
    s = s.split('//')[0].strip()
    return [item.strip() for item in s.split(',')]

def gp000_format(funName, s_lst):
    rd = int2bin(s_lst[1][1:], 3)
    r0 = int2bin(s_lst[2][1:], 3)
    if s_lst[3][0] == 'R':
        r1 = int2bin(s_lst[3][1:], 3)
    else:
        r1 = int2bin(s_lst[3], 3)
    return f'{fun15_11[funName]}_{rd}_{r0}_{r1}_{fun1_0[funName]}'

def gp001_format(funName, s_lst):
    rd  = int2bin(s_lst[1][1:], 3)
    r0  = int2bin(s_lst[2][1:], 3)
    imm = int2bin(s_lst[3], 5)
    return f'{fun15_11[funName]}_{rd}_{r0}_{imm}'

def gp010_format(funName, s_lst):
    r0  = int2bin(s_lst[1][1:], 3)
    r1  = int2bin(s_lst[2][1:], 3)
    imm = int2bin(s_lst[3], 5)
    return f'{fun15_11[funName]}_{imm[0:3]}_{r0}_{r1}_{imm[3:]}'

def gp011_format(funName, s_lst):
    rd  = int2bin(s_lst[1][1:], 3)
    imm = int2bin(s_lst[2], 8) 
    return f'{fun15_11[funName]}_{rd}_{imm}'

def gp100_format(funName, s_lst):
    rd  = int2bin(s_lst[1][1:], 3)
    imm = int2bin(s_lst[2], 8) 
    if funName == 'LD':
        return f'{fun15_11[funName]}_{rd}_{imm}'
    if funName == 'SD':
        return f'{fun15_11[funName]}_{imm[0:6]}_{rd}_{imm[6:]}'
    return ''

# def chnage(s)
def readCommandFile(ass_file, mach_file):
    w_file = open(mach_file, 'w')
    lineCnt = 0
    with open(ass_file, 'r') as file:
        for line in file:
            s_lst = readAssCode(line)
            print(s_lst)
            funName = s_lst[0]
            mach_code = ''
            if funName in ['ADD' ,'SUB' ,'MUL' ,'AND' ,'OR'  ,'XOR' ,'SLL' ,'SRL' ,'SLLI','SRLI']:
                mach_code = gp000_format(funName, s_lst)
            if funName in ['ANDI', 'ORI' , 'XORI', 'ADDI']:
                mach_code = gp001_format(funName, s_lst)
            if funName in ['BEQ', 'BLT', 'BNE']:
                mach_code = gp010_format(funName, s_lst)
            if funName in ['JAL']:
                mach_code = gp011_format(funName, s_lst)
            if funName in ['LD', 'SD']:
                mach_code = gp100_format(funName, s_lst)
            lineHex = format(lineCnt, '04x')
            w_file.write(f'inst_mem[16\'h{lineHex}] = 16\'b{mach_code};\n')
            lineCnt += 1
    w_file.close()
    print('readCommandFile done!!!')

readCommandFile('tb_ass_mach_code/assCode_tb_ass.txt', 'tb_ass_mach_code/machCode.txt')

