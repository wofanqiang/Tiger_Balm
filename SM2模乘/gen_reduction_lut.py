def gen_retuction_lut(file_name, p, num_flag, step):
    f = open(file_name, 'w')
    #pb = (2**1024-p) * (2**(16*(58+1)))
    pb = (2 ** 256 - p)
    #temp_pb = pb % p
    

    data =  """module xpb_lut
(
    input logic [5:0] flag[%(num_flag)d],
    output logic [255:0] xpb[%(num_xpb)d]
);
        
        
""" % {'num_flag': num_flag*3, 'num_xpb': num_flag * 3}
    for j in range(num_flag):
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[%(j)d])\n'% { 'j': j*3}
        for i in range(2**6):
            data = data + '            6\'d%(i)d: xpb[%(j)d] = 256\'d%(k)d;\n' % {'i': i, 'j': j*3, 'k':((pb * (2**(j*step))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[%(j)d])\n'% { 'j': j*3+1}
        for i in range(2**6):
            data = data + '            6\'d%(i)d: xpb[%(j)d] = 256\'d%(k)d;\n' % {'i': i, 'j': j * 3 + 1, 'k':((pb * (2**(j*step + 6))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
        data = data + '    always_comb begin\n'
        data = data + '        case(flag[%(j)d])\n'% { 'j': j*3+2}
        for i in range(2**6):
            data = data + '            6\'d%(i)d: xpb[%(j)d] = 256\'d%(k)d;\n' % {'i': i, 'j': j * 3 + 2, 'k':((pb * (2**(j*step + 6+6))) * i)%p}
        data = data + '        endcase\n'
        data = data + '    end\n\n'
    data = data + '\n\nendmodule'

    data = data + '\n\n\n\n'
    
    f.write(data)
        

    f.close()

if __name__ == "__main__":
    #存储文件
    file_name = "./xpb_lut.sv"
    #模数
    p = 0xFFFFFFFE_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_FFFFFFFF_FFFFFFFF
    #约减标志位的个数（17bit一段，每段3产生三个xpb）
    num_flag = 19
    #约减标志位的权值（进位）
    step = 16

    gen_retuction_lut(file_name, p, num_flag, step)