# LAB AWS IaC — Terraform + GitHub Actions

EC2 (Nginx) + Security Group + S3 privado + CloudWatch Log Group en `us-east-1`,
desplegados desde la rama `develop` con GitHub Actions autenticado por OIDC.

```
bootstrap/   bucket de estado + rol OIDC (se aplica una vez, desde tu PC)
infra/       la infraestructura del laboratorio
.github/workflows/terraform.yml
```

## 1. Bootstrap (desde tu PC)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # completar
terraform init
terraform apply
terraform output                                # AWS_ROLE_ARN y TF_STATE_BUCKET
```

## 2. Configurar GitHub (Settings → Secrets and variables → Actions)

| Tipo     | Nombre          | Valor                                          |
|----------|-----------------|------------------------------------------------|
| Secret   | AWS_ROLE_ARN    | output del bootstrap                           |
| Secret   | TF_STATE_BUCKET | output del bootstrap                           |
| Variable | LAB_BUCKET_NAME | nombre único, ej. `lab-iac-data-apellido-2026` |
| Variable | LAB_HTTP_CIDR   | tu IP pública + `/32` (`curl ifconfig.me`)     |

## 3. Primer despliegue

```bash
git checkout -b develop   # si no existe
git add . && git commit -m "lab iac: infraestructura inicial"
git push -u origin develop
```

Actions → revisar el Summary (plan + outputs) → abrir `web_url` en el navegador.

## 4. Experimentos (un commit por experimento, editando infra/variables.tf)

| # | Cambio | Qué esperar en el plan |
|---|--------|------------------------|
| 1 | `instance_type` t3.micro → t3.small | `~` update in-place (AWS para y arranca la instancia). Volver a t3.micro |
| 2 | `log_retention_days` 7 → 14 | `~` update solo en el log group; EC2 y S3 sin cambios |
| 3 | `environment` dev → qa | `-/+` log group y SG (cambia el nombre), EC2 reemplazada (cambia user_data), tags `~`. Volver a dev |
| 4 | variable LAB_BUCKET_NAME en GitHub | `-/+` bucket. Si tiene objetos/versiones, el destroy falla. Lanzar con Run workflow → apply |

## 5. Limpieza

1. Vaciar el bucket de datos si se le subió algo (consola S3 → Empty).
2. Actions → Run workflow → `destroy` + escribir `DESTROY`.
3. Verificar en consola que no quedan EC2, SG, S3 ni log group.
4. Recién al final: `cd bootstrap && terraform destroy`.

## Actividad evaluativa

1. **¿Qué cambia al modificar el tipo EC2?** Es un update in-place: Terraform cambia `instance_type` sin crear otra instancia, pero AWS tiene que pararla y volver a arrancarla (corte de servicio; sin Elastic IP la IP pública cambia). También cambia el costo por hora.
2. **¿Por qué S3 no se puede renombrar?** El nombre del bucket es su identificador global e inmutable; AWS no tiene operación de rename. Terraform marca `bucket` como "forces replacement": destruye y crea otro, y los datos hay que migrarlos aparte (un bucket con objetos o versiones no se puede borrar).
3. **¿Diferencia entre plan y apply?** `plan` compara código, estado y realidad y muestra qué haría, sin tocar nada. `apply` ejecuta los cambios y actualiza el estado. El workflow guarda el plan (`-out=tfplan`) y aplica exactamente ese.
4. **¿Por qué OIDC es mejor que claves estáticas?** No hay access keys guardadas en GitHub que puedan filtrarse o haya que rotar: cada ejecución pide a STS credenciales temporales que vencen solas, y la trust policy limita qué repo y qué rama pueden asumir el rol.
5. **Commit y su cambio en AWS:** captura del commit, del plan en el Summary del workflow y del recurso modificado en la consola.
