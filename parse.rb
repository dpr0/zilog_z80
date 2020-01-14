# ruby parse.rb filename
require 'byebug'
require 'minitest/autorun'

class Disassembler
    #             0       1       2       3       4       5       6       7
    T_R   = [    'B',    'C',    'D',    'E',    'H',    'L', '(HL)',    'A']
    T_CC  = [   'NZ',    'Z',   'NC',    'C',   'PO',   'PE',    'P',    'M']
    T_ALU = [  'ADD',  'ADC',  'SUB',  'SBC',  'AND',  'XOR',   'OR',   'CP']
    T_ROT = [  'RLC',  'RRC',   'RL',   'RR',  'SLA',  'SRA',  'SLL',  'SRL']
    T_IM  = [    '0',  '0/1',    '1',    '2',    '0',  '0/1',    '1',    '2']
    T_RP  = [   'BC',   'DE',   'HL',   'SP']
    T_RP2 = [   'BC',   'DE',   'HL',   'AF']

    def initialize(file_name)
        @file_name = file_name
        @x = 0; @y = 0; @z = 0; @p = 0; @q = 0;
        @d = 0; @n = 0; @nn = 0; @i = 0; @mem = nil
        @prefix = nil
    end

    def start
        result_file = File.open("#{@file_name}.txt", 'w')

        File.open(@file_name).each_byte do |byte|
            bin = byte.to_s(2).rjust(8, '0')
            load_vars(bin)
            str = case @prefix
                  when 'cb' then CB_prefix
                  when 'ed' then ED_prefix
                  when 'dd' then DD_prefix
                  when 'fd' then FD_prefix
                  when 2
                    @i -= 1
                    if @i == 0
                        @prefix = nil
                        @mem + byte.to_s(16).rjust(2, '0') + @temp
                    else
                        @temp = byte.to_s(16).rjust(2, '0')
                        nil
                    end
                  when 1
                    @prefix = nil
                    @mem + byte.to_s(16).rjust(2, '0')
                  else command
                  end
            result_file << (str + "\n") if str
        end

        result_file.close
    end

    private

    def load_vars(bin)
        @x = bin[0..1].to_i(2)
        @y = bin[2..4].to_i(2)
        @z = bin[5..7].to_i(2)
        @p = bin[2..3].to_i(2)
        @q = bin[4] == 1 ? true : false
    end

    def command
        case @x
        when 0
            case @z
            when 0
                case @y
                when 0 then 'NOP'
                when 1 then 'EX AF, AF\''
                when 2 then "DJNZ #{@d}"
                when 3 then "JR #{@d}"
                else        "JR #{T_CC[@y-4]},#{@d}"
                end
            when 1 then @q ? "ADD HL,#{T_RP[@p]}" : calc_bytes("LD #{T_RP[@p]},#", 2)
            when 2
                a1 = @p == 2 ? 'HL' : 'A'
                a2 = ['(BC)','(DE)',"(#{@nn})","(#{@nn})"]
                'LD ' + (@q ? "#{a1},#{a2[@p]}" : "#{a2[@p]},#{a1}")
            when 3 then "#{@q ? 'DEC' : 'INC'} #{T_RP[@p]}"
            when 4 then "INC #{T_R[@y]}"
            when 5 then "DEC #{T_R[@y]}"
            when 6 then "LD #{T_R[@y]},#{@n}"
            when 7 then ['RLCA','RRCA','RLA','RRA','DAA','CPL','SCF','CCF'][@y]
            end
        when 1 then @y == 6 ? 'HALT' : "LD #{T_R[@y]},#{T_R[@z]}"
        when 2 then "#{T_ALU[@y]} #{T_R[@z]}"
        when 3
            case @z
            when 0 then "RET #{T_CC[@y]}"
            when 1 then @q ? ['RET','EXX','JP HL','LD SP, HL'][@p] : "POP #{T_RP2[@p]}"
            when 2 then "JP #{T_CC[@y]},#{@nn}"
            when 3 then ["JP #{@nn}", set_prefix('cb'), "OUT (#{@n}),A", "IN A,(#{@n})", "EX (SP),HL", "EX DE,HL", 'DI', 'EI'][@y]
            when 4 then "CALL #{T_CC[@y]},#{@nn}"
            when 5 then @q ? ["CALL #{@nn}", set_prefix('dd'), set_prefix('ed'), set_prefix('fd')][@p] : "PUSH #{T_RP2[@p]}"
            when 6 then "#{T_ALU[@y]} #{@n}"
            when 7 then "RST #{@y*8}"
            end
        end
    end

    def calc_bytes(str, b)
        @prefix = b
        @i = b
        @mem = str
        nil
    end

    def set_prefix(code)
        @prefix == code
        nil
    end

    def CB_prefix
        @prefix = nil
        ["#{T_ROT[@y]} ", 'BIT y,', 'RES y,', 'SET y,'][@x] + T_R[@z]
    end

    def ED_prefix
        @prefix = nil
        if @x == 1
            case @z
            when 0 then "IN #{ "#{T_R[@y]}," if @y != 6}(C)"
            when 1 then "OUT (C),#{@y == 6 ? 0 : T_R[@y]}"
            when 2 then "#{@q ? 'ADC' : 'SBC'} HL,#{T_RP[@p]}"
            when 3 then 'LD ' + (@q ? "#{T_RP[@p]},(#{@nn})" : "(#{@nn}),#{T_RP[@p]}")
            when 4 then 'NEG'
            when 5 then @y == 1 ? 'RETI' : 'RETN'
            when 6 then "IM #{T_IM[@y]}"
            when 7 then ['LD I,A','LD R,A','LD A,I','LD A,R','RRD','RLD','NOP','NOP'][@y]
            end
        elsif @x == 2 && @z <= 3 && @y >= 4
            [['LDI','CPI','INI','OUTI'],['LDD','CPD','IND','OUTD'],['LDIR','CPIR','INIR','OTIR'],['LDDR','CPDR','INDR','OTDR']][@y - 4][@z]
        else
            'NOP'
        end
    end

    def DD_prefix
        @prefix = nil
        'NOP'
    end

    def FD_prefix
        @prefix = nil
        'NOP'
    end
end

class TestMe < Minitest::Test
  def test_Result
    Disassembler.new('parse.C').start
    assert_equal File.read('parse.txt'), File.read('parse.C.txt')
  end
end

start_time = Time.now
Disassembler.new(ARGV[0]).start
puts "Memory: %d kbyte." % (`ps -o rss= -p #{Process.pid}`)
puts "Time: #{Time.now - start_time} sec."

# F3
# 31
# 00
# 61
# 3E
# 07
# 06
# 02
# 90
# FE
# 06
# 28
# 06
# 38
# 0A
# 30
# 0E
# F3
# 76
# 3E
# 00
# D3
# FE
# F3
# 76
# 3E
# 01
# D3
# FE
# F3
# 76
# 3E
# 02
# D3
# FE
# F3
# 76