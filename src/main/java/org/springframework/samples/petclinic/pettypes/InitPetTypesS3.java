package org.springframework.samples.petclinic.pettypes;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.samples.petclinic.owner.PetType;

import software.amazon.awssdk.core.ResponseInputStream; // <-- FIXED import
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

@ConditionalOnProperty(name = "app.run.platform", havingValue = "aws")

@Component
public class InitPetTypesS3 implements InitializingBean {

	private static final Logger logger = LoggerFactory.getLogger(InitPetTypesS3.class);

	private final PetTypesRepository petTypesRepository;

	private final S3Client s3Client;

	@Value("${app.init.pet-types.s3.bucket}")
	private String bucket;

	@Value("${app.init.pet-types.s3.key:petclinic-pettypes.txt}")
	private String objectKey;

	public InitPetTypesS3(PetTypesRepository petTypesRepository, S3Client s3Client) {
		this.petTypesRepository = petTypesRepository;
		this.s3Client = s3Client; // auto-created by Spring Cloud AWS when region/creds
									// are set
	}

	@Override
	@Transactional
	public void afterPropertiesSet() throws Exception {
		if (bucket == null || bucket.isBlank()) {
			logger.info("S3 bucket not configured, skipping loading pet types.");
			return;
		}
		if (objectKey == null || objectKey.isBlank()) {
			logger.info("S3 object key not configured, skipping loading pet types.");
			return;
		}

		logger.info("Loading Pet types from s3://{}/{}", bucket, objectKey);
		byte[] fileContents = downloadObject(bucket, objectKey);
		if (fileContents == null || fileContents.length == 0) {
			logger.info("S3 object is empty or missing; nothing to load.");
			return;
		}

		List<PetType> foundTypes = new String(fileContents, StandardCharsets.UTF_8).lines()
			.map(String::trim)
			.filter(s -> !s.isEmpty())
			.map(name -> {
				PetType t = new PetType();
				t.setName(name);
				return t;
			})
			// use Collectors.toList() for Java 8/11 compatibility
			.collect(Collectors.toList());

		logger.info("Found {} pet types", foundTypes.size());

		if (!foundTypes.isEmpty()) {
			petTypesRepository.saveAllAndFlush(foundTypes);

			// clean up the file if we've successfully loaded from it
			logger.info("Deleting init object s3://{}/{}", bucket, objectKey);
			s3Client.deleteObject(DeleteObjectRequest.builder().bucket(bucket).key(objectKey).build());
		}
	}

	private byte[] downloadObject(String bucket, String key) {
		try (ResponseInputStream<GetObjectResponse> in = s3Client
			.getObject(GetObjectRequest.builder().bucket(bucket).key(key).build());
				ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
			copy(in, baos);
			return baos.toByteArray();
		}
		catch (Exception e) {
			logger.warn("Failed to download s3://{}/{}: {}", bucket, key, e.toString());
			return null;
		}
	}

	private static void copy(InputStream in, ByteArrayOutputStream out) throws Exception {
		byte[] buf = new byte[8192];
		int r;
		while ((r = in.read(buf)) != -1) {
			out.write(buf, 0, r);
		}
	}

}
