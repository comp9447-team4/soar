from datetime import datetime

#wrapper function used to log all function calls of the tool and log it in a local file called ./logs

#global vars

log_file_path = "../../logs/runtime.logs"

def log_file_writer(file_loc, messages):

    try:
        with open (file_loc, 'a') as f:
            for i in messages:
                f.write(i)

    except Exception as e:
        print(f"Something went wrong went writing to a file, {e}")

def log_function(func):
    def wrap (*arg, **kwargs):
        start_time = datetime.now()
        res = func()
        end_time = datetime.now()


        start_time_str = start_time.strftime("%m/%d/%Y, %H:%M:%S")
        message_exec = f"{start_time_str}: Executed function {func.__name__}"
        end_time_str = end_time.strftime("%m/%d/%Y, %H:%M:%S")
        diff_str = (end_time - start_time).microseconds
        message_time_el = f"{end_time_str}: Time taken to execute {func.__name__} {diff_str} microseconds"
        
        log_file_writer(log_file_path, [message_exec, message_time_el])

        return res
        
