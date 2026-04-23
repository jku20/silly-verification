`ifndef TEST_BENCH_SV
`define TEST_BENCH_SV

package test_bench;

class TestBench;
  local bit all_asserts_passed;
  local int num_tests;
  local int num_tests_passed;

  function new;
    this.all_asserts_passed = 1;
    this.num_tests = 0;
    this.num_tests_passed = 0;
  endfunction

  task test_begin;
    this.num_tests += 1;
    this.all_asserts_passed = 1;
  endtask

  task test_end;
    this.num_tests_passed += this.all_checks_passed() ? 1 : 0;
  endtask

  task check_32b_eq (
    input logic [31:0] received,
    input logic [31:0] expected
  );
    if (expected !== received) begin
      $display("\033[31mERROR\033[39m: expected %d but recieved %d", expected, received);
      this.all_asserts_passed = 0;
    end
  endtask: check_32b_eq

  task check_8b_eq (
    input logic [7:0] received,
    input logic [7:0] expected
  );
    if (expected !== received) begin
      $display("\033[31mERROR\033[39m: expected %d but recieved %d", expected, received);
      this.all_asserts_passed = 0;
    end
  endtask: check_8b_eq

  task assert_false;
    this.all_asserts_passed = 0;
  endtask

  function bit all_checks_passed;
    all_checks_passed = this.all_asserts_passed;
  endfunction

  function bit all_tests_passed;
    all_tests_passed = this.num_tests == this.num_tests_passed;
  endfunction

  task display_test_results;
    $display("\033[32m%0d/%0d tests passed\033[39m", this.num_tests_passed, this.num_tests);
    if (this.all_tests_passed()) $display("\033[32mALL TESTS PASSED\033[39m");
    else                         $display("\033[31mTESTS FAILED\033[39m");
  endtask
endclass

endpackage: test_bench

`endif /* TEST_BENCH_SV */
