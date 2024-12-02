function RSCname = gridcase_to_RSCname(gridcase)
    if contains(gridcase, 'struct') || contains(gridcase, '_C_')
        RSCname = 'C';
    elseif contains(gridcase, 'horz') || contains(gridcase, '_HC_')
        RSCname = 'HC';
    elseif contains(gridcase, 'cart') || contains(gridcase, '_CC_')
        RSCname = 'CC';
    elseif contains(gridcase, 'gq') || contains(gridcase, '_QT')
        RSCname = 'QT';
    elseif contains(gridcase, '5tet') || contains(gridcase, '_T')
        RSCname = 'T';
    elseif contains(gridcase, 'cPEBI') || contains(gridcase, '_PEBI')
        RSCname = 'PEBI';
    else
        RSCname = gridcase;
    end
end