package org.springframework.samples.petclinic.pettypes;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.samples.petclinic.owner.PetType;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

@ConditionalOnProperty(name = "app.run.platform", havingValue = "local", matchIfMissing = true)
@Component
public class InitPetTypesLocal implements InitializingBean {

	private static final Logger logger = LoggerFactory.getLogger(InitPetTypesLocal.class);

	private final PetTypesRepository petTypesRepository;

	/**
	 * Path to the local file containing newline-separated pet type names.
	 */
	@Value("${app.init.pet-types.local.path:./petclinic-pettypes.txt}")
	private String petTypesFilePath;

	public InitPetTypesLocal(PetTypesRepository petTypesRepository) {
		this.petTypesRepository = petTypesRepository;
	}

	@Override
	@Transactional
	public void afterPropertiesSet() throws Exception {
		Path filePath = Paths.get(petTypesFilePath);

		if (!Files.exists(filePath)) {
			logger.info("No local pet types file found at {}, skipping load.", filePath.toAbsolutePath());
			return;
		}

		logger.info("Loading Pet types from local file {}", filePath.toAbsolutePath());

		byte[] fileContents = readFile(filePath);

		if (fileContents.length == 0) {
			logger.info("Local file is empty; nothing to load.");
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
			.collect(Collectors.toList());

		logger.info("Found {} pet types", foundTypes.size());

		if (!foundTypes.isEmpty()) {
			petTypesRepository.saveAllAndFlush(foundTypes);

			logger.info("Deleting local pet types file {}", filePath.toAbsolutePath());
			try {
				Files.delete(filePath);
			}
			catch (IOException e) {
				logger.warn("Failed to delete local file {}: {}", filePath, e.toString());
			}
		}
	}

	private byte[] readFile(Path path) {
		try {
			return Files.readAllBytes(path);
		}
		catch (IOException e) {
			logger.warn("Failed to read local file {}: {}", path, e.toString());
			return new byte[0];
		}
	}

}
