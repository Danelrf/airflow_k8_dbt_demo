from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator
from airflow.operators.bash import BashOperator


with DAG(
        'airflow_k8_dbt_demo',
        # These args will get passed on to each operator
        # You can override them on a per-task basis during operator initialization
        default_args={
            'depends_on_past': False,
            'email': ['airflow@example.com'],
            'email_on_failure': False,
            'email_on_retry': False,
            'retries': 1,
            'retry_delay': timedelta(minutes=5)
        },
        description='A simple tutorial DAG',
        schedule_interval=timedelta(days=1),
        start_date=datetime(2022, 1, 1),
        catchup=False,
        tags=['example', 'K8s_dbt_default_amd']
) as dag:
    dbt_run = KubernetesPodOperator(
        namespace="composer-user-workloads",  # the new namespace you've created in the Workload Identity creation process
        # service_account_name="composer", # the new k8 service account you've created in the Workload Identity creation process
        image="eu.gcr.io/danel-dbt-project/airflow-k8-dbt-demo:1.0.1",
        cmds=["bash", "-cx"],
        arguments=["dbt run --project-dir dbt_k8_demo"],
        labels={"foo": "bar"},
        name="dbt-run-k8",
        task_id="run_dbt_job_on_k8_demo",
        image_pull_policy="Always",
        get_logs=True,
        # Specifies path to kubernetes config. The config_file is templated.
        config_file="/home/airflow/composer_kube_config",
        # Identifier of connection that should be used
        kubernetes_conn_id="kubernetes_default",
        dag=dag
        )
    
    # kubernetes_min_pod = KubernetesPodOperator(
    #     # The ID specified for the task.
    #     task_id="pod-ex-minimum",
    #     # Name of task you want to run, used to generate Pod ID.
    #     name="pod-ex-minimum",
    #     # Entrypoint of the container, if not specified the Docker container's
    #     # entrypoint is used. The cmds parameter is templated.
    #     cmds=["echo"],
    #     # The namespace to run within Kubernetes. In Composer 2 environments
    #     # after December 2022, the default namespace is
    #     # `composer-user-workloads`. Always use the
    #     # `composer-user-workloads` namespace with Composer 3.
    #     namespace="composer-user-workloads",
    #     # Docker image specified. Defaults to hub.docker.com, but any fully
    #     # qualified URLs will point to a custom repository. Supports private
    #     # gcr.io images if the Composer Environment is under the same
    #     # project-id as the gcr.io images and the service account that Composer
    #     # uses has permission to access the Google Container Registry
    #     # (the default service account has permission)
    #     image="gcr.io/gcp-runtimes/ubuntu_20_0_4",
    #     # Specifies path to kubernetes config. The config_file is templated.
    #     config_file="/home/airflow/composer_kube_config",
    #     # Identifier of connection that should be used
    #     kubernetes_conn_id="kubernetes_default",
# )
    dbt_run.dry_run()

