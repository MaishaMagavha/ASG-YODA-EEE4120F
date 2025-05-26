clc; clear;

% === Test Cases ===
a1_list = [1.0, 0.5, 4.0, 100.0, 2.5, 1.0, -3.0, 0.0];
d_list = [0.5, 0.25, -1.0, 10.0, 0.15625, 0.00390625, 1.5, 0.00390625];
n_list = [4, 4, 4, 3, 1, 4, 4, 255];

% Verilog simulated cycle times (based on your FSM)
verilog_times = [50, 50, 50, 40, 20, 50, 50, 2560];  % ns

% Settings
reps = 1e5;  % Number of repetitions for averaging
matlab_times = zeros(1, length(a1_list));
results = zeros(1, length(a1_list));

fprintf("Starting MATLAB ASG Benchmark\n");
fprintf("Averaging each test over %d repetitions\n\n", reps);

% === Test Loop ===
for i = 1:length(a1_list)
    a1 = a1_list(i);
    d = d_list(i);
    n = n_list(i);

    % Warm up MATLAB JIT
    tmp = a1 + d * (0:n-1);

    % Start timer
    tic;
    for r = 1:reps
        sequence = a1 + d * (0:n-1);
        last_term = sequence(end);
    end
    elapsed = toc / reps * 1e9;  % Average time in ns

    matlab_times(i) = elapsed;
    results(i) = last_term;

    % Display info
    fprintf("==== Test %d ====\n", i);
    fprintf("a1     = %.6f\n", a1);
    fprintf("d      = %.6f\n", d);
    fprintf("n      = %d\n", n);
    fprintf("Result = %.6f\n", last_term);
    fprintf("Verilog Time = %d ns\n", verilog_times(i));
    fprintf("MATLAB Time  = %.2f ns (avg of %d runs)\n\n", elapsed, reps);
end

% === Speedup Calculation ===
speedup = matlab_times ./ verilog_times;

% === BAR GRAPH: Execution Time Comparison ===
figure;
bar([matlab_times' verilog_times'], 0.6);
set(gca, 'XTickLabel', {'Test 1','Test 2','Test 3','Test 4','Test 5','Test 6','Test 7','Test 8'});
legend('MATLAB (avg ns)', 'Verilog (sim ns)', 'Location', 'northwest');
title('Execution Time Comparison');
ylabel('Time (ns)');
xlabel('Test Case');
grid on;

% Labels
for i = 1:length(matlab_times)
    text(i-0.25, matlab_times(i)+50, sprintf('%.1f', matlab_times(i)), 'FontSize', 8);
    text(i+0.05, verilog_times(i)+50, sprintf('%d', verilog_times(i)), 'FontSize', 8);
end

% === LINE GRAPH: Speedup ===
figure;
plot(1:8, speedup, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b');
xticks(1:8);
xticklabels({'Test 1','Test 2','Test 3','Test 4','Test 5','Test 6','Test 7','Test 8'});
ylabel('Speedup (MATLAB / Verilog)');
xlabel('Test Case');
title('Speedup of Verilog vs MATLAB');
grid on;

for i = 1:length(speedup)
    text(i, speedup(i)+0.5, sprintf('%.1fx', speedup(i)), 'HorizontalAlignment', 'center');
end

% === Summary Table ===
fprintf('\n==== Summary Table ====\n');
fprintf('Test | n  | Verilog (ns) | MATLAB (ns) | Speedup\n');
fprintf('-----|----|--------------|-------------|--------\n');
for i = 1:length(a1_list)
    fprintf('%2d   | %3d | %12d | %11.1f | %6.2fx\n', ...
        i, n_list(i), verilog_times(i), matlab_times(i), speedup(i));
end
