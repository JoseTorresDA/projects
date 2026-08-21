SELECT

    -- 1. ID EMPLEADO
    CASE
        WHEN id_empleado REGEXP '^EMP[0-9]{4}$' THEN id_empleado
        WHEN id_empleado REGEXP '^EMP-' THEN CONCAT(
            'EMP',
            LPAD(REPLACE(id_empleado, 'EMP-', ''), 4, '0')
        )
        WHEN id_empleado = 'nan' THEN NULL
        ELSE CONCAT(
            'EMP',
            LPAD(REPLACE(id_empleado, '-', ''), 4, '0')
        )
    END AS id_empleado,

    -- 2. NOMBRE COMPLETO
    CONCAT(
        UPPER(LEFT(SUBSTRING_INDEX(TRIM(nombre_completo), ' ', 1), 1)),
        LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(nombre_completo), ' ', 1), 2)),
        ' ',
        UPPER(LEFT(SUBSTRING_INDEX(TRIM(nombre_completo), ' ', -1), 1)),
        LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(nombre_completo), ' ', -1), 2))
    ) AS nombre_completo,

    -- 3. GENERO
    CASE
        WHEN LOWER(TRIM(genero)) IN ('female', 'f', 'femenino', 'mujer')
            THEN 'F'
        WHEN LOWER(TRIM(genero)) IN ('male', 'masculino', 'hombre')
            THEN 'M'
        ELSE 'REVISAR'
    END AS genero,

    -- 4. FECHA DE NACIMIENTO
    CASE
        WHEN fecha_nacimiento_clean LIKE '____-__-__'
            THEN STR_TO_DATE(fecha_nacimiento_clean, '%Y-%m-%d')

        WHEN CAST(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(fecha_nacimiento_clean, '-', 2),
                '-',
                -1
            ) AS UNSIGNED
        ) > 12
            THEN STR_TO_DATE(fecha_nacimiento_clean, '%m-%d-%Y')

        ELSE STR_TO_DATE(fecha_nacimiento_clean, '%d-%m-%Y')
    END AS fecha_nacimiento,

    -- 5. FECHA DE CONTRATACION
    CASE
        WHEN fecha_contratacion_clean LIKE '____-__-__'
            THEN STR_TO_DATE(fecha_contratacion_clean, '%Y-%m-%d')

        WHEN CAST(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(fecha_contratacion_clean, '-', 2),
                '-',
                -1
            ) AS UNSIGNED
        ) > 12
            THEN STR_TO_DATE(fecha_contratacion_clean, '%m-%d-%Y')

        ELSE STR_TO_DATE(fecha_contratacion_clean, '%d-%m-%Y')
    END AS fecha_contratacion,

    -- 6. DEPARTAMENTO
    CASE
        WHEN TRIM(LOWER(departamento)) LIKE 'fina%'
            THEN 'Finanzas'

        WHEN TRIM(departamento) REGEXP '^(hr|rr|recursos)'
            THEN 'Recursos Humanos'

        WHEN TRIM(departamento) REGEXP '^(mkt|mark|merca)'
            THEN 'Marketing'

        WHEN TRIM(departamento) REGEXP '^(ops|oper)'
            THEN 'Operaciones'

        WHEN TRIM(departamento) REGEXP '^(it|ti|t.i|information|tec)'
            THEN 'Tecnología'

        WHEN TRIM(departamento) REGEXP '^(sales|ventas)'
            THEN 'Ventas'
    END AS departamento,

    -- 7. PUESTO
    puesto,

    -- 8. PAIS
    TRIM(
        CONCAT(
            UPPER(LEFT(pais, 1)),
            LOWER(RIGHT(pais, LENGTH(pais) - 1))
        )
    ) AS pais,

    -- 9. CIUDAD
    CASE
        WHEN TRIM(ciudad) REGEXP '^(Cdmx|Ciudad)'
            THEN 'Ciudad de México'

        WHEN TRIM(ciudad) REGEXP '^(Buenos)'
            THEN 'Buenos Aires'

        ELSE CONCAT(
            UPPER(SUBSTRING(TRIM(ciudad), 1, 1)),
            LOWER(SUBSTRING(TRIM(ciudad), 2))
        )
    END AS ciudad,

    -- 10. SALARIO MENSUAL
    CONCAT(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            salario_mensual,
                            '$',
                            ''
                        ),
                        ',',
                        ''
                    ),
                    '-',
                    ''
                ),
                ' COP',
                ''
            ),
            '.0',
            ''
        ),
        ''
    ) AS salario_mensual,

    -- 11. EMAIL
    CASE
        WHEN LOWER(TRIM(email)) LIKE '%@%.%'
            THEN email
        ELSE NULL
    END AS email,

    -- 12. TELEFONO
    CASE
        WHEN REGEXP_REPLACE(TRIM(telefono), '[+() ]', '')
            THEN CONCAT(
                '',
                RIGHT(
                    REGEXP_REPLACE(TRIM(telefono), '[+() ]', ''),
                    10
                )
            )
        ELSE NULL
    END AS telefono,

    -- 13. ID GERENTE
    CASE
        WHEN id_gerente REGEXP '^EMP[0-9]{4}$'
            THEN id_gerente

        WHEN id_gerente REGEXP '^EMP-'
            THEN CONCAT(
                'EMP',
                LPAD(REPLACE(id_gerente, 'EMP-', ''), 4, '0')
            )

        WHEN id_gerente = 'nan'
            THEN NULL

        ELSE CONCAT(
            'EMP',
            LPAD(REPLACE(id_gerente, '-', ''), 4, '0')
        )
    END AS id_gerente,

    -- 14. PUNTAJE DESEMPEÑO
    CASE
        WHEN puntaje_desempeno BETWEEN 1 AND 5
            THEN puntaje_desempeno
        ELSE NULL
    END AS puntaje_desempeno,

    -- 15. ESTADO
    CASE
        WHEN LOWER(estado) LIKE 'activ%'
            THEN 1

        WHEN LOWER(estado) LIKE 'inactiv%'
            THEN 0

        ELSE NULL
    END AS estado

FROM (
    
    -- LIMPIEZA DE FECHAS
    SELECT
        empleados_raw.*,

        CASE
            WHEN fecha_nacimiento LIKE '%/%'
                THEN REPLACE(fecha_nacimiento, '/', '-')
            WHEN fecha_nacimiento LIKE '%.%'
                THEN REPLACE(fecha_nacimiento, '.', '-')
            ELSE fecha_nacimiento
        END AS fecha_nacimiento_clean,

        CASE
            WHEN fecha_contratacion LIKE '%/%'
                THEN REPLACE(fecha_contratacion, '/', '-')
            WHEN fecha_contratacion LIKE '%.%'
                THEN REPLACE(fecha_contratacion, '.', '-')
            ELSE fecha_contratacion
        END AS fecha_contratacion_clean

    FROM empleados_raw

) AS datos_limpios;
