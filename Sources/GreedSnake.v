`timescale 1ns / 1ps

module GreedSnake(
    input clk, clkin, data_in,
    output [11:0]rgb,
    output hs, vs,
    output [7:0] an,
    output [6:0] c
    );
    reg pclk;
    initial begin
        pclk = 0;
    end
    always @( posedge clk ) begin
        pclk <= ~pclk;
    end
    //input 
    wire [7:0] key_info;
    wire [3:0] dirc1, dirc2;
    wire choose, rechoose, nxtcolor;
    wire restart, pause, ecs_pause;

    Keyboard_Input istream(
        .clk(clk), .clkin(clkin), .datain(data_in),
        .data(key_info)
    );
    KBCtrl kbctrl(
        .din(key_info),
        .dir1(dirc1), .dir2(dirc2),
        .choose(choose), .rechoose(rechoose), .nxtcolor(nxtcolor),
        .restart(restart), .pause(pause), .esc_pause(esc_pause)
    );
    //FSM
    wire continue, over;
    wire [3:0]state;
    FSM mainfsm(
        .clk(clk), .continue(continue), .pause(pause), .esc_pause(esc_pause), .restart(restart), .over(over), 
        .choose_en(state[0]), .playing_en(state[1]), .pause_en(state[2]), .over_en(state[3])
    );
    //choose color
    wire[11:0] body_input, head_input;
    wire[11:0] bodyA, headA, bodyB, headB;
    wire[2:0] addr;

    WriteColor colorwirter(
        .clk(clk), .en(state[0]),
        .body_color(body_input), .head_color(head_input),
        .choose_DBn(choose), .rechoose_DBn(rechoose), .nxtcolor_DBn(nxtcolor),
        .addr(addr), .body_A(bodyA), .head_A(headA), .body_B(bodyB), .head_B(headB),
        .continue(continue)
    );

    ColorFile colorfile(
        .clk(clk), .addr(addr),
        .body_color(body_input), .head_color(head_input)
    );
    //player
    wire[15:0] rdata;
    wire[1:0] winner;
    wire integer len_a, len_b;
    wire[2:0] food_time_out;
    wire[5:0] food_count;
    wire [12:0] waddr;
    wire [15:0] wdata;
    wire we;
    play_core core(
        .clk(pclk), .play(state[1]), .pause(pause), 
        .head_a_color(headA), .head_b_color(headB),
        .body_a_color(bodyA), .body_b_color(bodyB),
        .BTNL_a(dirc1[2]), .BTNR_a(dirc1[0]), .BTNU_a(dirc1[3]), .BTND_a(dirc1[1]),
        .BTNL_b(dirc2[2]), .BTNR_b(dirc2[0]), .BTNU_b(dirc2[3]), .BTND_b(dirc2[1]),
        .rdata(rdata), .who_win(winner), .over(over), .len_a(len_a), .len_b(len_b),
        .food_time_out(food_time_out), .food_count(food_count), .waddr(waddr), .wdata(wdata),
        .we(we)
    );
    wire game_board_data;

    //display
    wire [15:0] snake_data;
    wire [12:0] raddr1, raddr2;
    display dis(
        .pclk(pclk),
        .head_A(headA), .body_A(bodyA), .head_B(headB), .body_B(bodyB),
        .game_board_data(game_board_data), .snake_data(snake_data),
        .food_time(food_time_out), .food_count(food_count), 
        .state(state), .winner(winner), .len_a(len_a), .len_b(len_b), .raddr1(raddr1), .raddr2(raddr2),
        .rgb(rgb), .hs(hs), .vs(vs), .an(an), .c(c)
    );
    //RAM
    snake_RAM snake_RAM(
        .addra (waddr),
        .clka  (pclk),
        .dina  (wdata),
        .douta (rdata),
        .wea   (we),
        .addrb (raddr2),
        .clkb  (pclk),
        .dinb  (0),
        .doutb (snake_data),
        .web   (state[0])
    );
    game_board_RAM game_board_RAM(
        .addra (raddr1),
        .clka  (pclk),
        .dina  (0),
        .douta (game_board_data),
        .wea   (0),
        .addrb (0),
        .clkb  (pclk),
        .dinb  (0),
        .doutb (),
        .web   (0)
    );

endmodule
