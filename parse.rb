# Z80 ruby disassembler
# dvitvitskiy.pro@gmail.com
# https://github.com/dpr0
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
        @x = 0; @y = 0; @z = 0; @p = 0; @q = 0; @xx = nil
        @lyambda = nil; @prefix = nil; @prev = nil
    end

    def start
        result_file = File.open("#{@file_name}.txt", 'w')

        File.open(@file_name).each_byte do |byte|
            bin = byte.to_s(2).rjust(8, '0')
            load_vars(bin)
            str = case @prefix
                  when 'cb' then cb_prefix
                  when 'ed' then ed_prefix
                  when 'dd' then @xx = 'IX'; xx_prefix
                  when 'fd' then @xx = 'IY'; xx_prefix
                  when 2
                    @prefix -= 1
                    @temp = byte.to_s(16).rjust(2, '0').upcase; nil
                  when 1
                    resp = @lyambda.call(@arg, "#{byte.to_s(16).rjust(2, '0').upcase}")
                    @prefix = nil
                    temp = @temp; @temp = nil
                    if temp
                        if resp.include?(")")
                            resp = @xx ? displacement(temp.hex, resp) : resp.sub(")", "#{temp})").sub("(", "(#")
                        else
                            resp += temp
                        end
                    end
                    resp = @xx.nil? ? resp : resp.sub("HL", @xx)
                    @xx = nil
                    resp
                  when 'xx'
                    temp = @temp; @temp = nil
                    displacement(byte, temp)
                  else command
                  end
            @prev = byte.to_s(16)
            result_file << "    #{str.ljust(13, ' ')} ; \n" if str
        end

        result_file.close
    end

    private

    def displacement(byte, temp)
        @prefix = nil
        byte -= 256 if byte > 127
        des = ['', "+#{byte.to_s}", byte.to_s][byte <=> 0]
        resp = temp.sub("HL", @xx + des)
        resp
    end

    def load_vars(bin)
        @x = bin[0..1].to_i(2)
        @y = bin[2..4].to_i(2)
        @z = bin[5..7].to_i(2)
        @p = bin[2..3].to_i(2)
        @q = bin[4] == '1' ? true : false
    end

    def command
        case @x
        when 0
            case @z
            when 0
                case @y
                when 0 then 'NOP'
                when 1 then 'EX AF, AF\''
                when 2 then calc_bytes(->(a, b){ "DJNZ ##{b}" }, nil, 1)
                when 3 then calc_bytes(->(a, b){ "JR ##{b}" }, nil, 1)
                else        calc_bytes(->(a, b){ "JR #{a},##{b}" }, T_CC[@y-4], 1)
                end
            when 1 then @q ? "ADD HL,#{T_RP[@p]}" : calc_bytes(->(a, b){ "LD #{a},##{b}" }, T_RP[@p], 2)
            when 2
                a1 = @p == 2 ? 'HL' : 'A'
                if @p > 1
                    calc_bytes((@q ? ->(a, b){ "LD #{a},(#{b})" } : ->(a, b){ "LD (#{b}),#{a}" }), a1, 2)
                else
                    a2 = ['(BC)','(DE)'][@p]
                    'LD ' + (@q ? "#{a1},#{a2}" : "#{a2},#{a1}")
                end
            when 3 then "#{@q ? 'DEC' : 'INC'} #{T_RP[@p]}"
            when 4 then "INC #{T_R[@y]}"
            when 5 then "DEC #{T_R[@y]}"
            when 6 then calc_bytes(->(a, b){ "LD #{a},##{b}" }, T_R[@y], 1)
            when 7 then ['RLCA','RRCA','RLA','RRA','DAA','CPL','SCF','CCF'][@y]
            end
        when 1 then @z == 6 && @y == 6 ? 'HALT' : "LD #{T_R[@y]},#{T_R[@z]}"
        when 2 then "#{T_ALU[@y]} #{T_R[@z]}"
        when 3
            case @z
            when 0 then "RET #{T_CC[@y]}"
            when 1 then @q ? ['RET','EXX','JP HL','LD SP, HL'][@p] : "POP #{T_RP2[@p]}"
            when 2 then calc_bytes(->(a, b){ "JP #{a},#{b}" }, T_CC[@y], 2)
            when 3
                case @y
                when 0 then calc_bytes(->(a, b){ "JP ##{b}" }, nil, 2)
                when 1 then @prefix = 'cb'; nil
                when 2 then calc_bytes(->(a, b){ "OUT (##{b}),A" }, nil, 1)
                when 3 then calc_bytes(->(a, b){ "IN A,(##{b})" }, nil, 1)
                when 4 then "EX (SP),HL"
                when 5 then "EX DE,HL"
                when 6 then 'DI'
                when 7 then 'EI'
                end
            when 4 then calc_bytes(->(a, b){ "CALL #{a},##{b}" }, T_CC[@y], 2)
            when 5 
                if @q
                    case @p
                    when 0 then calc_bytes(->(a, b){ "CALL ##{b}" }, nil, 2)
                    when 1 then @prefix = 'dd'; nil
                    when 2 then @prefix = 'ed'; nil
                    when 3 then @prefix = 'fd'; nil
                    end
                else
                    "PUSH #{T_RP2[@p]}"
                end
            when 6 then calc_bytes(->(a, b){ "#{a} ##{b}" }, T_ALU[@y], 1)
            when 7 then "RST #{@y*8}"
            end
        end
    end

    def calc_bytes(lyambda, arg, bb)
        @prefix  = bb
        @arg     = arg
        @lyambda = lyambda
        nil
    end

    def cb_prefix
        @prefix = nil
        ["#{T_ROT[@y]} ", "BIT #{@y},", "RES #{@y},", "SET #{@y},"][@x] + T_R[@z]
    end

    def ed_prefix
        @prefix = nil
        if @x == 1
            case @z
            when 0 then "IN #{ "#{T_R[@y]}," if @y != 6}(C)"
            when 1 then "OUT (C),#{@y == 6 ? 0 : T_R[@y]}"
            when 2 then "#{@q ? 'ADC' : 'SBC'} HL,#{T_RP[@p]}"
            when 3 then calc_bytes((@q ? ->(a, b){ "LD #{a},(#{b})" } : ->(a, b){ "LD #{b},(#{a})" }), T_RP[@p], 2)
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

    def xx_prefix # dd fd prefix
        @temp = command
        if @temp && @temp.include?('(')
            @prefix = 'xx'
            nil
        else
            @prefix = 2
            @temp
        end
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
