% Klasör yolunu tanımla
klasor_yolu = 'test';

% Klasördeki tüm .txt dosyalarını al
dosya_listesi = dir(fullfile(klasor_yolu, '*.txt'));

% Tüm dosyaları işle
for dosya_index = 1:numel(dosya_listesi)
    dosya_adi = dosya_listesi(dosya_index).name;
    dosya_yolu = fullfile(klasor_yolu, dosya_adi);
    
    % Dosyayı aç
    dosya = fopen(dosya_yolu, 'r');
    
    % Dosya içeriğini hücre dizisine oku
    dosya_icerik = textscan(dosya, '%s', 'Delimiter', '\n');
    dosya_icerik = dosya_icerik{1};
    
    % Dosyayı kapat
    fclose(dosya);
    
    % Matrislerin başlangıç satırını belirle
    matris_baslangic_satiri = find(strcmp(dosya_icerik, 'SSD'));

    
    % Ana struct oluştur
    ana_struct = struct();
    
    % İş sayısı ve makine sayısı alanlarını doldur
    [is_sayisi, makine_sayisi, ~] = strread(dosya_icerik{1}, '%d %d %d');
    ana_struct.is_sayisi = is_sayisi;
    ana_struct.makine_sayisi = makine_sayisi;
    
    % Calisma sureleri matrisini al
    calisma_sureleri = zeros(is_sayisi, makine_sayisi*2); % Satır sayısı: iş sayısı, Sütun sayısı: makine sayısı
    for i = 1:is_sayisi
        satir_verisi = strsplit(dosya_icerik{i+2}, ' '); % Satırı boşluğa göre ayır
        satir_verisi = cellfun(@str2double, satir_verisi); % String değerleri double'a çevir
        disp(satir_verisi);
        calisma_sureleri(i, :) = satir_verisi(1:makine_sayisi*2); % Sadece makine sayısına kadar olan değerleri al
    end
    ana_struct.calisma_sureleri = calisma_sureleri;
    
    % Makine iş setup zamanları için alt struct oluştur
    %makine_is_setup_struct = struct();
    %matris_verisi = zeros(is_sayisi, is_sayisi); 
    % Matrislerin başlangıç ve bitiş satırlarını bul
  a = 0;
    for i = 1:makine_sayisi
     matris_verisi = zeros(is_sayisi, is_sayisi); 
        for j = 1:is_sayisi + 1
            try
             satir_verisi = dosya_icerik{matris_baslangic_satiri+j + 1};  
              satir_verisi = strsplit(satir_verisi, ' ');
              satir_verisi = cellfun(@str2double, satir_verisi);
               if any(isnan(satir_verisi))
               continue;
               end
               disp(satir_verisi);
             % Satır verisini matrisin ilgili satırına ekle
               matris_verisi(j, :) = satir_verisi(1:is_sayisi);
             % matris_baslangic_satiri = matris_baslangic_satiri + 1;
            catch
            continue
            end
        end
        matris_adi = ['M' num2str(i-1)];
        eval(['ana_struct.' matris_adi ' = matris_verisi;']);
        %makine_is_setup_struct.(['M' num2str(a)]) = matris_verisi;
        matris_baslangic_satiri =  matris_baslangic_satiri + is_sayisi +1;
        a = a + 1;
        disp("---------------------------");
    end

    
    % Ana struct içine alt struct'ı yerleştir
    %ana_struct.makine_is_setup_time = makine_is_setup_struct;
    
    % Dosya adını kullanarak mat dosyası adını oluştur
    [dosya_adi_temiz, ~] = strtok(dosya_adi, '.');
    mat_dosya_adi = [dosya_adi_temiz '.mat'];
    
    % Mat dosyasına kaydet
    save(mat_dosya_adi, '-struct', 'ana_struct');
end