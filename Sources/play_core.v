`timescale 1ns / 1ps

module play_core #(
    parameter time_per_step = 7_500_000,
    parameter total_food = 36,
    parameter food_a_color = 12'h48F,
    parameter food_b_color = 12'h00F,
    //FSM DEFINE
    parameter WRITE_SNAKE = 2'b00,
    parameter UPDATE_SNAKE = 2'b01,
    parameter PAUSING = 2'b10,
    parameter GAME_OVER = 2'b11,
    //UPDATE DEFINE
    parameter IDLE = 5'b00000,
    parameter DEL_TAILA = 5'b00001,
    parameter DEL_TAILB = 5'b00010,
    parameter PNT_TAILA = 5'b00011,
    parameter PNT_TAILB = 5'b00100,
    parameter PNT_HEADA = 5'b00101,
    parameter PNT_HEADB = 5'b00110,
    parameter JUG_EATA = 5'b00111,
    parameter JUG_EATB = 5'b01000,
    parameter CHANGE_DIRC_TAILA = 5'b01001,
    parameter CHANGE_DIRC_TAILB = 5'b01010,
    parameter EXT_TAILA = 5'b01011,
    parameter GET_INFO_TAILA = 5'b01100,
    parameter CHANGE_TO_TAILB = 5'b01101,
    parameter GET_INFO_TAILB = 5'b01110,
    parameter EXT_TAILB = 5'b01111,
    parameter SET_FOOD = 5'b10000,
    parameter GET_INFO_FOOD = 5'b10001,
    parameter JUG_FOOD_LOCTION = 5'b10010,
    parameter CHANGE_DIRC = 5'b10011,
    parameter LOCK_A = 5'b10100,
    parameter LOCK_B = 5'b10101,
    parameter LOCK = 5'b10110
)(
    input clk,
    input play, pause,

    input [11:0] head_a_color, head_b_color,
    input [11:0] body_a_color, body_b_color,

    input BTNL_a, BTNR_a, BTNU_a, BTND_a,
    input BTNL_b, BTNR_b, BTNU_b, BTND_b,

    input [15:0] rdata,
    
    output reg [1:0] who_win,
    output reg over,
    output integer len_a, len_b,
    output [2:0] food_time_out,
    output reg [5:0] food_count,
    output wire [12:0] waddr,
    output reg [15:0] wdata,
    output reg we
);
    
    // 00 --- paint the snake
    // 01 --- update the snake
    // 10 --- pausing
    // 11 --- game is over
    reg [1:0] state;

    // can be regarded as the FSM of state 00
    // 0 --- painting the snake b
    // 1 --- painting the snake a
    reg paint_a;

    // the FSM for state of state 01
    reg [4:0] update_state;

    integer time_count;


    reg [6:0] head_a_x, tail_a_x, head_b_x, tail_b_x, write_x;
    reg [6:0] head_a_y, tail_a_y, head_b_y, tail_b_y, write_y;
    reg [1:0] dirc_a, dirc_b, tail_dirc_a, tail_dirc_b;

    // serve for updater and mux
    reg [1:0] dirc;
    reg [6:0] ptr_x, ptr_y;
    wire [6:0] uptr_x, uptr_y;

    dirc_updater updater( dirc, ptr_x, ptr_y, uptr_x, uptr_y );
    //play PS
    reg s1, s2, s3;
    wire play_PS;
    initial begin 
        s1 = 0; 
        s2 = 0; 
        s3 = 0; 
    end
    always@(posedge clk)begin
        s1 <= play;
        s2 <= s1;
        s3 <= s2;
    end
    assign play_PS = s2 & (~s3);
    
    always @(*) begin
        case ( update_state )
            PNT_TAILA: begin
                dirc = rdata[3:2];
                ptr_x = tail_a_x; ptr_y = tail_a_y;
            end
            PNT_TAILB: begin
                dirc = rdata[3:2];
                ptr_x = tail_b_x; ptr_y = tail_b_y;
            end
            PNT_HEADA: begin
                dirc = dirc_a;
                ptr_x = head_a_x; ptr_y = head_a_y;
            end
            PNT_HEADB: begin
                dirc = dirc_b;
                ptr_x = head_b_x; ptr_y = head_b_y;
            end
            CHANGE_DIRC_TAILA: begin
                dirc = { rdata[3], ~rdata[2] };
                ptr_x = tail_a_x; ptr_y = tail_a_y;
            end
            EXT_TAILA: begin
                dirc = tail_dirc_a;
                ptr_x = write_x; ptr_y = write_y;
            end
            CHANGE_TO_TAILB: begin
                dirc = tail_dirc_b;
                ptr_x = tail_b_x; ptr_y = tail_b_y;
            end
            EXT_TAILB: begin
                dirc = tail_dirc_b;
                ptr_x = write_x; ptr_y = write_y;
            end
            default: begin
                dirc = 0;
                ptr_x = 0; ptr_y = 0;
            end
        endcase
    end
    // end of updater and mux part

    // part to deal with food
    reg eaten;
    reg [4:0] eat_a, eat_b;

    reg [6:0] food_time;
    wire [31:0] rand_num;

    assign food_time_out = food_time[6:4];

    rand_core rand(
        clk, 1, 
        time_count[1:0] == 2'b00, 
        rand_num
    );
    // end of food part

    initial begin
        state = 2'b11;
        update_state = IDLE;
        we = 0;
        over <= 0;
    end

    assign waddr = write_x + 
        { write_y, 6'b000000 } + { write_y, 3'b000 } + 
        { write_y, 1'b0 } + write_y;

    always @( posedge clk ) begin
        case ( state )
            GAME_OVER: begin
                // time
                time_count <= 0;

                // work to do
                over <= 0;
                we <= 0;
                update_state <= LOCK;

                // main FSM
                if ( play_PS ) begin
                    // main states
                    over <= 0;
                    state <= IDLE;
                    paint_a <= 1;
                    update_state <= IDLE;

                    // prepare for state 00
                    head_a_x <= 25; tail_a_x <= 25; head_b_x <= 49; tail_b_x <= 49;
                    head_a_y <= 49; tail_a_y <= 25; head_b_y <= 25; tail_b_y <= 49;
                    dirc_a <= 2'b11; dirc_b <= 2'b10;
                    len_a <= 25; len_b <= 25;

                    write_x <= 25; write_y <= 49;
                    wdata <= { head_a_color, 4'b1101 };
                    we <= 1;
                end
            end

            WRITE_SNAKE: begin
                // time
                time_count <= 0;

                // work to do
                if ( paint_a ) begin
                    // now paint the snake a
                    if ( write_y == 25 ) begin
                        // tail has been painted
                        write_x <= 49;
                        wdata <= { head_b_color, 4'b1010 };
                        paint_a <= 0;
                    end
                    else begin
                        // paint the body of snake a
                        write_y <= write_y - 1;
                        wdata <= { body_a_color, 4'b1101 }; 
                    end
                end
                else begin
                    if ( write_y == 49 ) begin
                        // tail has been painted
                        // prepare for state 01
                        we <= 0;
                        state <= UPDATE_SNAKE;
                        update_state <= IDLE;
                    end
                    else begin
                       // paint the body of snake b
                        write_y <= write_y + 1;
                        wdata <= { body_b_color, 4'b1010 }; 
                    end
                end
            end

            UPDATE_SNAKE: begin
                // time
                if ( time_count == time_per_step - ( 36 - food_count ) * 100000 ) begin
                    time_count <= 1;
                    update_state <= DEL_TAILA;
                end
                else time_count <= time_count + 1;

                // main FSM
                if ( pause && ( update_state == 5'b10011 || update_state == 5'b10100) )
                    state <= PAUSING;

                // work to do
                case ( update_state )
                    // wait to begin
                    IDLE: begin
                        we <= 0;
                        who_win <= 0; eaten <= 1;
                        food_count <= total_food;
                        food_time <= 0;
                        eat_a <= 0; eat_b <= 0;
                    end
                    // set write to tail a and erase
                    DEL_TAILA: begin
                        we <= 1;
                        wdata <= 0;
                        write_x <= tail_a_x; write_y <= tail_a_y;
                        update_state <= DEL_TAILB;
                    end
                    // set write to tail b and erase
                    DEL_TAILB: begin
                        wdata <= 0;
                        write_x <= tail_b_x; write_y <= tail_b_y;
                        update_state <= PNT_TAILA;
                    end
                    // set write to head a and paint; update tail a
                    PNT_TAILA: begin
                        wdata <= { body_a_color, dirc_a, 2'b01 };
                        write_x <= head_a_x; write_y <= head_a_y;
                        tail_a_x <= uptr_x; tail_a_y <= uptr_y;
                        update_state <= PNT_TAILB;
                    end
                    // set write to head b and paint; update tail b
                    PNT_TAILB: begin
                        wdata <= { body_b_color, dirc_b, 2'b10 };
                        write_x <= head_b_x; write_y <= head_b_y;
                        tail_b_x <= uptr_x; tail_b_y <= uptr_y;
                        update_state <= PNT_HEADA;
                    end
                    // set write to new head a and paint; update head a
                    PNT_HEADA: begin
                        wdata <= { head_a_color, dirc_a, 2'b01 };
                        write_x <= uptr_x; write_y <= uptr_y;
                        head_a_x <= uptr_x; head_a_y <= uptr_y;
                        update_state <= PNT_HEADB;
                    end
                    // set write to new head b and paint; update head b
                    PNT_HEADB: begin
                        wdata <= { head_b_color, dirc_b, 2'b10 };
                        write_x <= uptr_x; write_y <= uptr_y;
                        head_b_x <= uptr_x; head_b_y <= uptr_y;
                        update_state <= JUG_EATA;
                    end
                    // process info about what snake a eats; set write to tail a
                    JUG_EATA: begin
                        case ( rdata[1:0] )
                            2'b01: who_win <= 2'b01;
                            2'b10: who_win <= 2'b01;
                            2'b11: begin
                                eaten <= 1;
                                if ( rdata[2] ) begin
                                    eat_a <= { 1'b1, food_time[6:3] };
                                    food_time <= 0;
                                end
                                else eat_a <= 16;
                            end
                        endcase
                        write_x <= tail_a_x; write_y <= tail_a_y;
                        we <= 0;
                        update_state <= JUG_EATB;
                    end
                    // process info about what snake b eats; set write to tail b
                    JUG_EATB: begin
                        case ( rdata[1:0] )
                            2'b00: begin
                                if ( who_win[0] ) begin
                                    state <= GAME_OVER;
                                    over <= 1;
                                end
                            end
                            2'b01: begin
                                // b eat a
                                if ( who_win[0] || ( head_a_x == head_b_x && head_a_y == head_b_y ) ) begin
                                    // a eats snake or two heads meet
                                    if ( len_a == len_b )     who_win <= 2'b11;
                                    else if ( len_a < len_b ) who_win <= 2'b01;
                                    else                      who_win <= 2'b10; 
                                end
                                else who_win <= 2'b10;
                                state <= GAME_OVER;
                                over <= 1;
                            end
                            2'b10: begin
                                // b eat b
                                if ( who_win[0] ) begin
                                    // a eats snake too
                                    if ( len_a == len_b )     who_win <= 2'b11;
                                    else if ( len_a < len_b ) who_win <= 2'b01;
                                    else                      who_win <= 2'b10; 
                                end
                                else who_win <= 2'b10;
                                state <= GAME_OVER;
                                over <= 1;
                            end
                            2'b11: begin
                                eaten <= 1;
                                if ( rdata[2] ) begin
                                    eat_b <= { 1'b1, food_time[6:3] };
                                    food_time <= 0;
                                end
                                else eat_b <= 16;

                                if ( who_win[0] ) begin
                                    state <= GAME_OVER;
                                    over <= 1;
                                end
                            end
                        endcase
                        write_x <= tail_b_x; write_y <= tail_b_y;
                        update_state <= CHANGE_DIRC_TAILA;
                    end
                    // set write to new tail; update tail dirc a
                    CHANGE_DIRC_TAILA: begin
                        we <= 1;
                        tail_dirc_a <= { rdata[3], ~rdata[2] };
                        wdata <= rdata;
                        write_x <= uptr_x; write_y <= uptr_y;
                        update_state <= CHANGE_DIRC_TAILB;
                    end
                    // update tail dirc b
                    CHANGE_DIRC_TAILB: begin
                        tail_dirc_b <= { rdata[3], ~rdata[2] };
                        update_state <= EXT_TAILA;
                    end
                    // paint the next tail
                    EXT_TAILA: begin
                        if ( eat_a == 0 || rdata[1:0] != 2'b00 ) begin
                            wdata <= rdata;
                            eat_a <= 0;
                            update_state <= CHANGE_TO_TAILB;
                        end
                        else begin
                            tail_a_x <= write_x; tail_a_y <= write_y;
                            write_x <= uptr_x; write_y <= uptr_y;
                            eat_a <= eat_a - 1; len_a <= len_a + 1;
                            update_state <= GET_INFO_TAILA;
                        end
                    end
                    // wait to get tail info
                    GET_INFO_TAILA: update_state <= EXT_TAILA;
                    // set write to new tail b
                    CHANGE_TO_TAILB: begin
                        wdata <= { body_b_color, 
                            tail_dirc_b[1], ~tail_dirc_b[0], 2'b10 };
                        write_x <= uptr_x; write_y <= uptr_y;
                        update_state <= GET_INFO_TAILB;
                    end
                    // wait to get info
                    GET_INFO_TAILB: update_state <= EXT_TAILB;
                    // paint the next tail
                    EXT_TAILB: begin
                        if ( eat_b == 0 || rdata[1:0] != 2'b00 ) begin
                            wdata <= rdata;
                            eat_b <= 0;
                            update_state <= SET_FOOD;
                        end
                        else begin
                            tail_b_x <= write_x; tail_b_y <= write_y;
                            write_x <= uptr_x; write_y <= uptr_y;
                            eat_b <= eat_b - 1; len_b <= len_b + 1;
                            update_state <= GET_INFO_TAILB;
                        end
                    end
                    // get place to give food
                    SET_FOOD: begin
                        if ( eaten ) begin
                            if ( food_count == 0 ) begin
                                if ( len_a == len_b )     who_win <= 2'b11;
                                else if ( len_a < len_b ) who_win <= 2'b01;
                                else                      who_win <= 2'b10;
                                state <= GAME_OVER;
                                over <= 1;
                            end
                            else begin
                                we <= 0;
                                eaten <= 0;
                                food_count <= food_count - 1;
                                if ( food_count[1:0] == 2'b01 ) begin
                                    food_time <= 7'b1111111;
                                    wdata <= { food_b_color, 4'b0111 };
                                end
                                else begin
                                    food_time <= 7'b0000000;
                                    wdata <= { food_a_color, 4'b0011 };
                                end
                                write_x <= rand_num[31:16] % 75;
                                write_y <= rand_num[15:0] % 75;
                                update_state <= GET_INFO_FOOD;
                            end
                        end
                        else begin
                            we <= 0;
                            if ( food_count[1:0] == 2'b00 && food_time != 0 )
                                food_time <= food_time - 1;
                            update_state <= CHANGE_DIRC;
                        end
                    end
                    // wait to get info
                    GET_INFO_FOOD: update_state <= JUG_FOOD_LOCTION;
                    // judge whether need to give number again
                    JUG_FOOD_LOCTION: begin
                        if ( rdata[1] | rdata[0] ) begin
                            write_x <= rand_num[31:16] % 75;
                            write_y <= rand_num[15:0] % 75;
                            update_state <= GET_INFO_FOOD;
                        end
                        else begin
                            we <= 1;
                            update_state <= CHANGE_DIRC;
                        end
                    end
                    // change dirc
                    CHANGE_DIRC: begin
                        we <= 0;
                        if ( dirc_a[1] ) begin
                            if ( BTNL_a ) begin
                                dirc_a <= 2'b00;
                                update_state <= LOCK_A;
                            end
                            else if ( BTNR_a ) begin
                                dirc_a <= 2'b01;
                                update_state <= LOCK_A;
                            end
                        end
                        else begin
                            if ( BTNU_a ) begin
                                dirc_a <= 2'b10;
                                update_state <= LOCK_A;
                            end
                            else if ( BTND_a ) begin
                                dirc_a <= 2'b11;
                                update_state <= LOCK_A;
                            end
                        end

                        if ( dirc_b[1] ) begin
                            if ( BTNL_b ) begin
                                dirc_b <= 2'b00;
                                update_state <= LOCK_B;
                            end
                            else if ( BTNR_b ) begin
                                dirc_b <= 2'b01;
                                update_state <= LOCK_B;
                            end
                        end
                        else begin
                            if ( BTNU_b ) begin
                                dirc_b <= 2'b10;
                                update_state <= LOCK_B;
                            end
                            else if ( BTND_b ) begin
                                dirc_b <= 2'b11;
                                update_state <= LOCK_B;
                            end
                        end
                    end
                    LOCK_A: begin
                        if ( dirc_b[1] ) begin
                            if ( BTNL_b ) begin
                                dirc_b <= 2'b00;
                                update_state <= LOCK;
                            end
                            else if ( BTNR_b ) begin
                                dirc_b <= 2'b01;
                                update_state <= LOCK;
                            end
                        end
                        else begin
                            if ( BTNU_b ) begin
                                dirc_b <= 2'b10;
                                update_state <= LOCK;
                            end
                            else if ( BTND_b ) begin
                                dirc_b <= 2'b11;
                                update_state <= LOCK;
                            end
                        end
                    end
                    LOCK_B: begin
                        if ( dirc_a[1] ) begin
                            if ( BTNL_a ) begin
                                dirc_a <= 2'b00;
                                update_state <= LOCK;
                            end
                            else if ( BTNR_a ) begin
                                dirc_a <= 2'b01;
                                update_state <= LOCK;
                            end
                        end
                        else begin
                            if ( BTNU_a ) begin
                                dirc_a <= 2'b10;
                                update_state <= LOCK;
                            end
                            else if ( BTND_a ) begin
                                dirc_a <= 2'b11;
                                update_state <= LOCK;
                            end
                        end
                    end
                    LOCK:;
                    // default
                    default: update_state <= CHANGE_DIRC;
                endcase
            end

            PAUSING: begin
                // main FSM
                if ( play_PS ) state <= UPDATE_SNAKE;
            end

        endcase
    end
endmodule
