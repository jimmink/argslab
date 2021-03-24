function print_timemin(t, str_cl)
% PRINT_TIMEMIN is a small script that prints the time in a
% human-readable manner, divided into minutes, seconds and milliseconds.
% A string in the second section can be added for clarification.

    minutes = num2str(floor(t/60));
    seconds = floor(rem(t,60));
    if seconds < 10
        seconds = ['0',num2str(seconds)];
    else
        seconds = num2str(seconds);
    end
    milliseconds = round(1000*rem(t,1));
    if milliseconds < 10
        milliseconds = ['00',num2str(milliseconds)];
    elseif milliseconds < 100
        milliseconds = ['0',num2str(milliseconds)];
    else
        milliseconds = num2str(milliseconds);
    end
    fprintf(['Total ', str_cl, ' runtime: ',minutes,':',seconds,'(:',milliseconds,') min:s(:ms)\n']);

end