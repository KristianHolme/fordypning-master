function RSCname = gridcase_to_RSCname(gridcase)
    if contains(gridcase, 'struct')
        RSCname = 'C';
    elseif contains(gridcase, 'horz')
        RSCname = 'HC';
    elseif contains(gridcase, 'cart')
        RSCname = 'CC';
    elseif contains(gridcase, 'gq')
        RSCname = 'QT';
    elseif contains(gridcase, '5tet')
        RSCname = 'T';
    elseif contains(gridcase, 'cPEBI')
        RSCname = 'PEBI';
    else
        RSCname = gridcase;
    end
end