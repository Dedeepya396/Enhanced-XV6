# import pandas as pd
# import matplotlib.pyplot as plt

# def read_process_data(filename):
#     # Read the data, filtering out lines that don't start with 'GRAPH'
#     with open(filename, 'r') as f:
#         lines = f.readlines()

#     data = []
#     for line in lines:
#         if line.startswith('GRAPH'):
#             parts = line.strip().split()
#             # Extract the PID, total ticks, queue, and state
#             pid = parts[1]
#             total_ticks = int(parts[2])
#             queue = int(parts[3])
#             data.append((pid, total_ticks, queue))

#     return pd.DataFrame(data, columns=['pid', 'total_ticks', 'queue'])

# def plot_process_queue(data):
#     plt.figure(figsize=(12, 6))
    
#     for pid, group in data.groupby('pid'):
#         plt.plot(group['total_ticks'], group['queue'], label=f'PID {pid}', linewidth=2)

#     plt.title('Process Queue Timeline')
#     plt.xlabel('Time Elapsed (ticks)')
#     plt.ylabel('Queue ID')
#     plt.yticks(range(0, 4))  # Assuming queues are 0, 1, 2, 3
#     plt.xticks(range(0, data['total_ticks'].max() + 1, 5))  # Adjust x-ticks as needed

#     # Set the x-axis limit to show a higher range
#     plt.xlim(0, data['total_ticks'].max() + 20)  # Increase the upper limit by 20 ticks

#     plt.grid(True)
#     plt.legend()
#     plt.show()

# # Main execution
# if __name__ == "__main__":
#     filename = 'log.txt'  # Replace with your actual filename
#     data = read_process_data(filename)
#     plot_process_queue(data)
import pandas as pd
import matplotlib.pyplot as plt

def read_process_data(filename):
    """
    Reads process data from a specified log file.

    Args:
        filename (str): The path to the log file.

    Returns:
        pd.DataFrame: A DataFrame containing process IDs, total ticks, and queue IDs.
    """
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: The file '{filename}' was not found.")
        return pd.DataFrame(columns=['pid', 'total_ticks', 'queue'])

    data = []
    for line in lines:
        if line.startswith('GRAPH'):
            parts = line.strip().split()
            try:
                pid = parts[1]
                total_ticks = int(parts[2])
                queue = int(parts[3])
                data.append((pid, total_ticks, queue))
            except (IndexError, ValueError):
                print(f"Warning: Invalid line format: '{line.strip()}'")
    
    return pd.DataFrame(data, columns=['pid', 'total_ticks', 'queue'])

def plot_process_queue(data):
    """
    Plots the process queue over time.

    Args:
        data (pd.DataFrame): DataFrame containing process information.
    """
    plt.figure(figsize=(12, 6))

    # Group by PID and plot each group's data
    for pid, group in data.groupby('pid'):
        plt.plot(group['total_ticks'], group['queue'], label=f'PID {pid}', linewidth=2)

    plt.title('Process Queue Timeline')
    plt.xlabel('Time Elapsed (ticks)')
    plt.ylabel('Queue ID')
    
    # Set y-ticks dynamically based on unique queue values
    plt.yticks(sorted(data['queue'].unique()))
    
    # Set x-ticks dynamically based on total_ticks
    max_ticks = data['total_ticks'].max()
    plt.xticks(range(0, max_ticks + 1, max(1, max_ticks // 10)))  # Adjust x-ticks based on total ticks
    
    # Set the x-axis limit to show a higher range
    plt.xlim(0, max_ticks + 20)

    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    filename = 'log.txt'
    data = read_process_data(filename)
    
    if not data.empty:
        plot_process_queue(data)
