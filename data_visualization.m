%% CMPT 225 Final Project - Priority Queue Performance Graphs
%% Data Visualization Script

% Clear workspace
clear;
clc;
close all;

% Read data from CSV
data = readtable('benchmark_data.csv');

% Extract columns
n = data.n;
binary_time = data.binary_heap_ms;
pairing_time = data.pairing_heap_ms;
fibonacci_time = data.fibonacci_heap_ms;

%% Figure 1: Execution Time vs. Input Size (Linear Scale)
figure('Position', [100, 100, 900, 600]);
plot(n, binary_time, 'ro-', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r');
hold on;
plot(n, pairing_time, 'bs-', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b');
plot(n, fibonacci_time, 'gd-', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'g');
hold off;

xlabel('Number of Elements (n)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Execution Time (milliseconds)', 'FontSize', 14, 'FontWeight', 'bold');
title('Priority Queue Performance Comparison', 'FontSize', 16, 'FontWeight', 'bold');
legend('Binary Heap', 'Pairing Heap', 'Fibonacci Heap', 'Location', 'northwest', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 12);

%% Figure 2: Execution Time vs. Input Size (Log-Log Scale)
figure('Position', [100, 100, 900, 600]);
loglog(n, binary_time, 'r--o', 'LineWidth', 1);
hold on;
loglog(n, pairing_time, 'b-*', 'LineWidth', 1.5);
loglog(n, fibonacci_time, 'g-.', 'LineWidth', 2);

% Add theoretical complexity lines
n_fit = logspace(log10(min(n)), log10(max(n)), 100);
% O(n log n) reference line (scaled to match binary heap at n=1000)
ref_constant = binary_time(find(n == 1000)) / (1000 * log2(1000));
ref_nlogn = ref_constant * n_fit .* log2(n_fit);
loglog(n_fit, ref_nlogn, 'k--', 'LineWidth', 1.5, 'DisplayName', 'O(n log n)');

hold off;

xlabel('Number of Elements (n)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Execution Time (milliseconds)', 'FontSize', 14, 'FontWeight', 'bold');
title('Priority Queue Performance (Log-Log Scale)', 'FontSize', 16, 'FontWeight', 'bold');
legend('Binary Heap', 'Pairing Heap', 'Fibonacci Heap', 'O(n log n) reference', ...
       'Location', 'northwest', 'FontSize', 11);
grid on;
set(gca, 'FontSize', 12);

%% Figure 3: Speedup Ratio (Pairing vs Binary, Fibonacci vs Binary)
figure('Position', [100, 100, 900, 600]);
speedup_pairing = binary_time ./ pairing_time;
speedup_fibonacci = binary_time ./ fibonacci_time;

bar_width = 0.35;
bar(n - bar_width/2, speedup_pairing, bar_width, 'b', 'FaceAlpha', 0.7);
hold on;
bar(n + bar_width/2, speedup_fibonacci, bar_width, 'g', 'FaceAlpha', 0.7);
hold off;

xlabel('Number of Elements (n)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Speedup Ratio (Binary Heap Time / Other Heap Time)', 'FontSize', 14, 'FontWeight', 'bold');
title('Speedup Compared to Binary Heap Baseline', 'FontSize', 16, 'FontWeight', 'bold');
legend('Pairing Heap', 'Fibonacci Heap', 'Location', 'best', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 12);
xticklabels(n);

% Add horizontal line at y=1 (no speedup)
yline(1, 'r--', 'LineWidth', 1.5);

%% Figure 4: Operation Count Breakdown (Pie Charts for largest n)
figure('Position', [100, 100, 1200, 500]);

% Get largest n data
[~, idx] = max(n);
n_max = n(idx);

% Create subplot for each heap
subplot(1, 3, 1);
op_labels = {'Insert', 'Delete-Min'};
op_counts = [n_max, n_max];  % For binary heap
pie(op_counts, op_labels);
title(sprintf('Binary Heap (n = %d)', n_max), 'FontSize', 14);
colormap(gca, [0.8 0.2 0.2; 0.2 0.2 0.8]);

subplot(1, 3, 2);
pie(op_counts, op_labels);
title(sprintf('Pairing Heap (n = %d)', n_max), 'FontSize', 14);
colormap(gca, [0.2 0.6 0.2; 0.2 0.2 0.8]);

subplot(1, 3, 3);
pie(op_counts, op_labels);
title(sprintf('Fibonacci Heap (n = %d)', n_max), 'FontSize', 14);
colormap(gca, [0.6 0.6 0.2; 0.2 0.2 0.8]);

sgtitle('Operation Distribution for Largest Test Case', 'FontSize', 16, 'FontWeight', 'bold');

%% Figure 5: Memory Comparison (Estimated)
figure('Position', [100, 100, 900, 600]);

% Estimate memory per node (bytes)
% Binary heap: 8 bytes (double) + overhead = ~8
% Pairing heap: 3 pointers (24 bytes) + double (8) = ~32
% Fibonacci heap: 6 pointers (48 bytes) + double (8) + int (4) + bool (1) = ~61

binary_mem = 8 * n_max / 1024;      % KB
pairing_mem = 32 * n_max / 1024;
fibonacci_mem = 61 * n_max / 1024;

mem_data = [binary_mem; pairing_mem; fibonacci_mem];
bar(mem_data);
set(gca, 'XTickLabel', {'Binary Heap', 'Pairing Heap', 'Fibonacci Heap'});
ylabel('Estimated Memory (KB)', 'FontSize', 14, 'FontWeight', 'bold');
title(sprintf('Memory Usage Comparison (n = %d)', n_max), 'FontSize', 16, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12);

% Add value labels on bars
for i = 1:3
    text(i, mem_data(i) + 0.5, sprintf('%.1f KB', mem_data(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 11);
end


%% Figure 6: Time vs n (log scale with fitted curves)
figure('Position', [100, 100, 900, 600]);

% Fit power law: t = a * n^b
log_n = log(n);
log_binary = log(binary_time);
log_pairing = log(pairing_time);
log_fibonacci = log(fibonacci_time);

% Linear fit
p_binary = polyfit(log_n, log_binary, 1);
p_pairing = polyfit(log_n, log_pairing, 1);
p_fibonacci = polyfit(log_n, log_fibonacci, 1);

% Generate fitted curves
n_fit = logspace(log10(min(n)), log10(max(n)), 100);
fit_binary = exp(p_binary(2)) * n_fit .^ p_binary(1);
fit_pairing = exp(p_pairing(2)) * n_fit .^ p_pairing(1);
fit_fibonacci = exp(p_fibonacci(2)) * n_fit .^ p_fibonacci(1);

loglog(n, binary_time, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
hold on;
loglog(n, pairing_time, 'bs', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
loglog(n, fibonacci_time, 'gd', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
loglog(n_fit, fit_binary, 'r-', 'LineWidth', 1.5);
loglog(n_fit, fit_pairing, 'b-', 'LineWidth', 1.5);
loglog(n_fit, fit_fibonacci, 'g-', 'LineWidth', 1.5);
hold off;

xlabel('Number of Elements (n)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Execution Time (milliseconds)', 'FontSize', 14, 'FontWeight', 'bold');
title(sprintf('Empirical Complexity Fitting\nBinary: O(n^{%.2f}), Pairing: O(n^{%.2f}), Fibonacci: O(n^{%.2f})', ...
              p_binary(1), p_pairing(1), p_fibonacci(1)), 'FontSize', 14);
legend('Binary Heap (data)', 'Pairing Heap (data)', 'Fibonacci Heap (data)', ...
       'Binary fit', 'Pairing fit', 'Fibonacci fit', 'Location', 'northwest', 'FontSize', 10);
grid on;
set(gca, 'FontSize', 12);


%% Generate Summary Table
fprintf('\n========== BENCHMARK SUMMARY ==========\n');
fprintf('%-10s %-15s %-15s %-15s\n', 'n', 'Binary (ms)', 'Pairing (ms)', 'Fibonacci (ms)');
fprintf('%-10s %-15s %-15s %-15s\n', '----------', '---------------', '---------------', '---------------');
for i = 1:length(n)
    fprintf('%-10d %-15.2f %-15.2f %-15.2f\n', n(i), binary_time(i), pairing_time(i), fibonacci_time(i));
end
fprintf('\nSpeedup (Binary/Pairing):\n');
for i = 1:length(n)
    fprintf('n = %d: %.2fx\n', n(i), binary_time(i) / pairing_time(i));
end

% Export table to CSV for LaTeX
T = table(n, binary_time, pairing_time, fibonacci_time, ...
          'VariableNames', {'n', 'BinaryHeap_ms', 'PairingHeap_ms', 'FibonacciHeap_ms'});
writetable(T, 'summary_table.csv');

fprintf('Table exported to summary_table.csv\n');