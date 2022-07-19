

-- 养殖组
insert into breed_group(id, name, parent_group_id, note) values(1, 'g1', null, 'g1');
insert into breed_group(id, name, parent_group_id, note) values(2, 'g2', null, 'g2');
insert into breed_group(id, name, parent_group_id, note) values(3, 'g1-1', 1, 'g1-1');
insert into breed_group(id, name, parent_group_id, note) values(4, 'g1-2', 1, 'g1-2');
insert into breed_group(id, name, parent_group_id, note) values(5, 'g1-3', 1, 'g1-3');


-- 养殖个体
insert into breed(id, weight, length, breed_group_id, note) values(1, 11.0, 11.0, 3, null);
insert into breed(id, weight, length, breed_group_id, note) values(2, 12.0, 12.0, 3, null);
insert into breed(id, weight, length, breed_group_id, note) values(3, 13.0, 13.0, 3, null);
insert into breed(id, weight, length, breed_group_id, note) values(4, 14.0, 14.0, 3, null);
insert into breed(id, weight, length, breed_group_id, note) values(5, 15.0, 15.0, 3, null);
insert into breed(id, weight, length, breed_group_id, note) values(6, 16.0, 16.0, 3, null);


-- 分子组
insert into molecule_group(id, name, num, note) values(1, '180501', 48, 'g1');
insert into molecule_group(id, name, num, note) values(2, '180502', 48, 'g2');
insert into molecule_group(id, name, num, note) values(3, '180503', 48, 'g3');
insert into molecule_group(id, name, num, note) values(4, '180505', 48, 'g4');
insert into molecule_group(id, name, num, note) values(5, '180506', 48, 'g5');
insert into molecule_group(id, name, num, note) values(6, '180509', 48, 'g6');
insert into molecule_group(id, name, num, note) values(7, '180419', 48, 'g7');
insert into molecule_group(id, name, num, note) values(8, '180420', 48, 'g8');
insert into molecule_group(id, name, num, note) values(9, 'C1701', 48, 'g9');
insert into molecule_group(id, name, num, note) values(10, 'F0', 48, 'g10');
insert into molecule_group(id, name, num, note) values(11, 'F1', 48, 'g11');
insert into molecule_group(id, name, num, note) values(12, 'F2', 48, 'g12');
insert into molecule_group(id, name, num, note) values(13, 'F3', 48, 'g13');
insert into molecule_group(id, name, num, note) values(14, 'F4', 48, 'g14');

-- 分子数据
insert into molecule(id, molecule_group_id, locus, available_sample_num, allele_num, 
    effective_allele_num, observe_heterozygosity, expected_heterozygosity, inbreeding_coefficient, 
    polymorphic_information_content, hw_probability, hw_sign, effective_population,
    confidence_interval_start, confidence_interval_end, note)
values(1, 1, 'Hdh07', 46, 3.0, 2.690, 0.543, 0.635, 0.135, 0.550, 0.422, 'ns', 3.2, 2.2, 5.8, null);

insert into molecule(id, molecule_group_id, locus, available_sample_num, allele_num, 
    effective_allele_num, observe_heterozygosity, expected_heterozygosity, inbreeding_coefficient, 
    polymorphic_information_content, hw_probability, hw_sign, effective_population,
    confidence_interval_start, confidence_interval_end, note)
values(2, 1, 'Hr6', 46, 2.0, 1.115, 0.109, 0.104, 0.057, 0.097, 0.697, 'ns', null, null, null, null);

insert into molecule(id, molecule_group_id, locus, available_sample_num, allele_num, 
    effective_allele_num, observe_heterozygosity, expected_heterozygosity, inbreeding_coefficient, 
    polymorphic_information_content, hw_probability, hw_sign, effective_population,
    confidence_interval_start, confidence_interval_end, note)
values(3, 1, 'Hr18', 46, 2.0, 1.139, 0.130, 0.123, 0.070, 0.114, 0.636, 'ns', 8.9, 5.7, 12.7, null);

insert into molecule(id, molecule_group_id, locus, available_sample_num, allele_num, 
    effective_allele_num, observe_heterozygosity, expected_heterozygosity, inbreeding_coefficient, 
    polymorphic_information_content, hw_probability, hw_sign, effective_population,
    confidence_interval_start, confidence_interval_end, note)
values(4, 1, 'Hf48', 48, 4.0, 2.592, 0.229, 0.621, 0.627, 0.562, 0.000, '***', null, null, null, null);

insert into molecule(id, molecule_group_id, locus, available_sample_num, allele_num, 
    effective_allele_num, observe_heterozygosity, expected_heterozygosity, inbreeding_coefficient, 
    polymorphic_information_content, hw_probability, hw_sign, effective_population,
    confidence_interval_start, confidence_interval_end, note)
values(5, 1, 'Hf46', 48, 4.0, 1.550, 0.417, 0.359, 0.174, 0.332, 0.760, 'ns', null, null, null, null);

insert into molecule(id, molecule_group_id, locus, available_sample_num, allele_num, 
    effective_allele_num, observe_heterozygosity, expected_heterozygosity, inbreeding_coefficient, 
    polymorphic_information_content, hw_probability, hw_sign, effective_population,
    confidence_interval_start, confidence_interval_end, note)
values(6, 1, 'Hf26', 48, 3.0, 1.753, 0.417, 0.434, 0.030, 0.388, 0.137, 'ns', null, null, null, null);

insert into molecule(id, molecule_group_id, locus, available_sample_num, allele_num, 
    effective_allele_num, observe_heterozygosity, expected_heterozygosity, inbreeding_coefficient, 
    polymorphic_information_content, hw_probability, hw_sign, effective_population,
    confidence_interval_start, confidence_interval_end, note)
values(7, 1, 'Hf44', 47, 4.0, 3.332, 0.851, 0.707, 0.216, 0.641, 0.119, 'ns', null, null, null, null);

insert into molecule(id, molecule_group_id, locus, available_sample_num, allele_num, 
    effective_allele_num, observe_heterozygosity, expected_heterozygosity, inbreeding_coefficient, 
    polymorphic_information_content, hw_probability, hw_sign, effective_population,
    confidence_interval_start, confidence_interval_end, note)
values(8, 1, 'Hf58', 48, 3.0, 1.424, 0.354, 0.301, 0.189, 0.264, 0.527, 'ns', null, null, null, null);


-- 分组分子数据关系对比
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(1, 1, 1, 0.000, 0.000, null);
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(2, 1, 2, 0.092, 0.105, null);
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(3, 1, 3, 0.074, 0.081, null);
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(4, 1, 4, 0.060, 0.070, null);
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(5, 1, 5, 0.105, 0.109, null);
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(6, 1, 6, 0.068, 0.077, null);
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(7, 1, 7, 0.069, 0.084, null);
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(8, 1, 8, 0.055, 0.059, null);
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(9, 1, 9, 0.043, 0.066, null);
insert into molecule_group_cmp(id, molecule_group_small_id, molecule_group_big_id, unbiased_genetic_distance, genetic_differentiation_index, note)
values(10, 1, 10, 0.022, 0.042, null);
