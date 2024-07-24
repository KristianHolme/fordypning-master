function displayName = displayNameGrid(gridcase, specase)
    Amap = containers.Map;
    Amap('5tetRef2') = 'UU-M';
    Amap('5tetRef3') = 'UU-C';
    Amap('5tetRef2-2D') = 'UU-M-2D';
    Amap('6tetRef2') = 'U-M';
    Amap('6tetRef3') = 'U-C';
    Amap('5tetRef1') = 'UU-F';
    Amap('5tetRef4') = 'UU-C';
    Amap('6tetRef1') = 'U-F';
    Amap('semi188x38_0.3') = 'SS-C';
    Amap('semi203x72_0.3') = 'SS-M';
    Amap('semi263x154_0.3') = 'SS-F';
    Amap('struct220x90') = 'S-M/F';
    Amap('struct340x150') = 'S-F';
    Amap('struct193x83') = 'S-M';
    Amap('5tetRef10') = 'UU-superCoarse';

    
    Bmap = containers.Map;
    % Bmap('5tetRef0.4') = 'UU-F';%59k
    % Bmap('5tetRef0.8') = 'UU-M';%16k
    % Bmap('5tetRef2') = 'UU-C';%3k
    % Bmap('6tetRef2') = 'U-C';
    % Bmap('6tetRef0.8') = 'U-M';
    % Bmap('6tetRef0.4') = 'U-F';
    % Bmap('struct420x141') = 'S-F';%54k
    % Bmap('semi188x38_0.3') = 'SS-C';
    % Bmap('semi203x72_0.3') = 'SS-M';
    % Bmap('semi263x154_0.3') = 'SS-F';
    % Bmap('5tetRef2-stretch') = 'UU-M-Astretch';
    % Bmap('5tetRef1-stretch') = 'UU-F-Astretch';
    % Bmap('5tetRef6-stretch') = 'UU-C-Astretch';
    %Master:
    Bmap('') = 'Cp-C';
    Bmap('horz_pre_cut_PG_130x62') = 'HPCP-C';
    Bmap('horz_ndg_cut_PG_130x62') = 'HNCP-C';
    Bmap('cart_pre_cut_PG_130x62') = 'CPCP-C';
    Bmap('cart_ndg_cut_PG_130x62') = 'CNCP-C';

    Bmap('horz_pre_cut_PG_220x110') = 'HPCP-M';
    Bmap('horz_ndg_cut_PG_220x110') = 'HNCP-M';
    Bmap('cart_pre_cut_PG_220x110') = 'CPCP-M';
    Bmap('cart_ndg_cut_PG_220x110') = 'CNCP-M';

    Bmap('horz_pre_cut_PG_819x117') = 'HPCP-F';
    Bmap('horz_ndg_cut_PG_819x117') = 'HNCP-F';
    % Bmap('horz_ndg_cut_PG_819x117') = 'Horizon-Cut';
    Bmap('cart_pre_cut_PG_819x117') = 'CPCP-F';
    Bmap('cart_ndg_cut_PG_819x117') = 'CNCP-F';
    % Bmap('cart_ndg_cut_PG_819x117') = 'Cartesian-Cut';

    Bmap('horz_ndg_cut_PG_1638x234') = 'HNCP-F2';
    Bmap('horz_ndg_cut_PG_2640x380') = 'HNCP-F3';
    Bmap('cart_ndg_cut_PG_1638x234') = 'CNCP-F2';
    Bmap('cart_ndg_cut_PG_2640x380') = 'CNCP-F3';

    Bmap('horz_pre_cut_130x62') = 'HPC-S';
    Bmap('cart_pre_cut_130x62') = 'CPC-S';
    Bmap('struct130x62') = 'C-C';
    Bmap('struct220x110') = 'C-M';
    Bmap('struct819x117') = 'C-F';
    Bmap('struct1638x234') = 'C-F2';
    Bmap('struct2640x380') = 'C-F3';

    % Bmap('struct819x117') = 'Cartesian';

    Bmap('cPEBI_130x62') = 'cPEBI-C';
    Bmap('cPEBI_220x110') = 'cPEBI-M';
    Bmap('cPEBI_819x117') = 'cPEBI-F';
    % Bmap('cPEBI_819x117') = 'PEBI';

    Bmap('5tetRef0.31') = 'T-F';
    % Bmap('5tetRef0.31') = 'Triangles';

    Bmap('gq_pb0.19') = 'QT-F';


    % C
    Cmap = containers.Map;
    Cmap('struct20x20x20') = 'C-20';
    Cmap('struct50x50x50') = 'C-50';
    Cmap('horz_ndg_cut_PG_50x50x50') = 'HNCP-50';
    Cmap('cart_ndg_cut_PG_50x50x50') = 'CNCP-50';
    Cmap('tet_zx10-F') = 'Tet-F';

    if strcmpi(specase, 'a')
        if isKey(Amap, gridcase)
            displayName = Amap(gridcase);
        else
            displayName = gridcase;
        end
    elseif strcmpi(specase, 'b')
        if isKey(Bmap, gridcase)
            displayName = Bmap(gridcase);
        else
            displayName = gridcase;
        end
    elseif strcmpi(specase, 'c')
        if isKey(Cmap, gridcase)
            displayName = Cmap(gridcase);
        else
            displayName = gridcase;
        end
    end

    
    
end