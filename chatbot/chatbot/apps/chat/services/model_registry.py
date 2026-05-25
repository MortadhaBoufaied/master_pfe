class ModelRegistry:
    _registry = {}

    @classmethod
    def register_components(cls, **components):
        cls._registry.update(components)

    @classmethod
    def get(cls, key):
        return cls._registry.get(key)

    @classmethod
    def get_tokenizer(cls):
        return cls.get('tokenizer')

    @classmethod
    def get_model(cls):
        return cls.get('falcon_model')

    @classmethod
    def get_lid_176_ftz(cls):
        return cls.get('lid_176_ftz')
