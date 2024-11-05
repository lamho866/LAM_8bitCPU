import re
import sys

fun15_11 = {
    'ADD'   :'00000',
    'SUB'   :'00000',
    'MUL'   :'00000',
    'AND'   :'00001',
    'OR'    :'00001',
    'XOR'   :'00001',
    'SLL'   :'00010',
    'SRL'   :'00010',
    'SLLI'  :'00011',
    'SRLI'  :'00011',
    'ANDI'  :'00100',
    'ORI'   :'00101',
    'XORI'  :'00110',
    'ADDI'  :'00111',
    'BEQ'   :'01000',
    'BLT'   :'01001',
    'BNE'   :'01010',
    'JAL'   :'01100',
    'LD'    :'10000',
    'SD'    :'10001',
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

def readOffset_reg_Bin(s):
    match = re.match(r"(\d+)\((\w+)\)", s)
    if match:
        imm = match.group(1)
        reg = match.group(2)
    else:
        print("No match found.")
    return int2bin(imm, 5), int2bin(reg[1:], 3)

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
    return f'{fun15_11[funName]}{rd}{r0}{r1}{fun1_0[funName]}'

def gp001_format(funName, s_lst):
    rd  = int2bin(s_lst[1][1:], 3)
    r0  = int2bin(s_lst[2][1:], 3)
    imm = int2bin(s_lst[3], 5)
    return f'{fun15_11[funName]}{rd}{r0}{imm}'

def gp010_format(funName, s_lst):
    #branch code
    r0  = int2bin(s_lst[1][1:], 3)
    r1  = int2bin(s_lst[2][1:], 3)
    imm = int2bin(s_lst[3], 5)
    assert imm[4] == '0', 'must input even number'
    return f'{fun15_11[funName]}{imm[0:3]}{r0}{r1}{imm[3:]}'

def gp011_format(funName, s_lst):
    #jal
    rd  = int2bin(s_lst[1][1:], 3)
    imm = int2bin(s_lst[2], 8) 
    assert imm[7] == '0', 'must input even number'
    return f'{fun15_11[funName]}{rd}{imm}'

def gp100_format(funName, s_lst):
    if funName == 'LD':
        rd  = int2bin(s_lst[1][1:], 3)
        imm, r0 = readOffset_reg_Bin(s_lst[2])
        return f'{fun15_11[funName]}{rd}{r0}{imm}'
    
    if funName == 'SD':
        r1  = int2bin(s_lst[1][1:], 3)
        imm, r0 = readOffset_reg_Bin(s_lst[2])
        # print(r1, imm, r0)
        return f'{fun15_11[funName]}{imm[0:3]}{r0}{r1}{imm[3:]}'
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
            # lineHex = format(lineCnt, '04x')
            if funName == 'END':
                mach_code = f'{"1"*16}'
            print(mach_code)
            w_file.write(f'{mach_code}\n')
            lineCnt += 1
    w_file.close()
    print('readCommandFile done!!!')

fName = 'tb_RF'
readCommandFile(f'{fName}.txt', f'{fName}Bin.txt')

