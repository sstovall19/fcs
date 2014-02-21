package com.fonality.dao;

import com.fonality.bu.entity.BundlePriceModel;
import com.fonality.bu.entity.TaxMapping;

public interface BundlePriceModelDAO {

    public TaxMapping getTaxMappingByPriceModelId(Integer bundleId, Integer priceModelId);

}
