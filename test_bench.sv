`ifndef TEST_BENCH_SV
`define TEST_BENCH_SV

package test_bench;

typedef enum {
  Passed, Failed, ToBeRun
} TestResult;

class Test;
  local string name;
  local TestResult result;

  function new(string name, TestResult result);
    this.name = name;
    this.result = result;
  endfunction

  function passed();
    passed = this.result == Passed;
  endfunction

  task pass();
    this.result = Passed;
  endtask

  task fail();
    this.result = Failed;
  endtask

  function string test_name();
    test_name = this.name;
  endfunction

endclass: Test

class TestArray;
  local int size;
  local Test store[];

  function new();
    this.size = 0;
    this.store = new [10];
  endfunction

  task double_size();
    Test new_arr[];
    new_arr = new[store.size() * 2];
    for (int i = 0; i < size; i++) begin
      new_arr[i] = store[i];
    end
    this.store = new_arr;
  endtask

  task add_test(string name);
    if (this.size == store.size())
      this.double_size();

    this.store[this.size++] = new(name, ToBeRun);
  endtask

  task pass_last_test();
    this.store[this.size-1].pass();
  endtask

  task fail_last_test();
    this.store[this.size-1].fail();
  endtask

  function string last_test_name();
    last_test_name = this.store[this.size-1].test_name();
  endfunction

  function int num_tests();
    num_tests = this.size;
  endfunction

  function int num_passed_tests();
    int acc = 0;
    for (int i = 0; i < this.size; i++) begin
      if (this.store[i].passed()) acc++;
    end

    num_passed_tests = acc;
  endfunction

  function bit all_tests_passed();
    all_tests_passed = this.num_passed_tests() == this.size;
  endfunction
endclass: TestArray

class TestBench;
  local bit all_asserts_passed;
  TestArray tests;

  function new();
    this.all_asserts_passed = 1;
    this.tests = new();
  endfunction

  task test_begin(string name);
    this.tests.add_test(name);
    this.all_asserts_passed = 1;
  endtask

  task test_end();
    if (this.all_checks_passed()) begin
      this.tests.pass_last_test();
      $display("\033[32mPASSED: %s\033[39m", this.tests.last_test_name());
    end else begin
      this.tests.fail_last_test();
      $display("\033[31mFAILED\033[32m: %s\033[39m", this.tests.last_test_name());
    end
  endtask

  task check_32b_eq (
    input logic [31:0] received,
    input logic [31:0] expected
  );
    if (expected !== received) begin
      $display("\033[31mERROR\033[39m: expected %0d but recieved %0d", expected, received);
      this.all_asserts_passed = 0;
    end
  endtask: check_32b_eq

  task check_8b_eq (
    input logic [7:0] received,
    input logic [7:0] expected
  );
    if (expected !== received) begin
      $display("\033[31mERROR\033[39m: expected %0d but recieved %0d", expected, received);
      this.all_asserts_passed = 0;
    end
  endtask: check_8b_eq

  task assert_false;
    this.all_asserts_passed = 0;
  endtask

  function bit all_checks_passed();
    all_checks_passed = this.all_asserts_passed;
  endfunction

  task display_test_results();
    $display("\033[32m%0d/%0d tests passed\033[39m", this.tests.num_passed_tests, this.tests.num_tests);
    if (this.tests.all_tests_passed()) $display("\033[32mALL TESTS PASSED\033[39m");
    else                               $display("\033[31mTESTS FAILED\033[39m");
  endtask
endclass

endpackage: test_bench

`endif /* TEST_BENCH_SV */
