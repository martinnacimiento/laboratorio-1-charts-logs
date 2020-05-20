<template>
  <div id="app">
    <chart
      :chartdata="retrasoDataSet"
      labelX="Tiempo por segundos"
      labelY="Tiempo de retraso en segundos"
      :EventsInfo="{ cant: events.length, groups }"
    ></chart>
    <chart
      :chartdata="bandwidthDataSet"
      labelX="Tiempo en segundos"
      labelY="Ancho de banda"
    ></chart>
  </div>
</template>
<script>
import Chart from "@/components/Chart";
import db from "@/db/db.json";
export default {
  components: { Chart },
  data: () => ({
    events: db,
    groups: null,
    retrasoDataSet: null,
  }),
  created() {
    this.groups = this.groupPerSecond();
    this.getPromedioAnchoDeBanda();
    this.getRetrasos();
    this.retrasoDataSet = {
      labels: this.getLabels(),
      datasets: [
        this.getRetrasoMinimo(),
        this.getPromedioRetraso(),
        this.getRetrasoMaximo(),
      ],
    };
    this.bandwidthDataSet = {
      labels: this.getLabels(),
      datasets: [this.getBandwidthPromedio()],
    };
  },
  methods: {
    getSecond(time) {
      let sec = Math.floor((time / 1000) % 60);
      return sec;
    },
    groupPerSecond() {
      let groups = [];
      let aux = this.events;
      this.events.sort((a, b) => {
        // console.log("Se genero: " + this.$moment(a.time).format());
        // console.log("LLego: " + this.$moment(a.time + a.timeDelay).format());

        return a.time - b.time;
      });

      let time = this.events[0].time;

      while (aux.length !== 0) {
        groups.push({
          timestamp: time,
          minute: this.getSecond(time),
          events: aux.filter(
            (e) => this.getSecond(time) === this.getSecond(e.time)
          ),
        });
        aux = aux.filter(
          (e) => this.getSecond(time) !== this.getSecond(e.time)
        );
        if (aux.length !== 0) {
          time = aux[0].time;
        }
      }
      return groups;
    },
    getLabels() {
      return this.groups.map((g) =>
        this.$moment(g.timestamp)
          .utc()
          .format("LTS")
      );
    },
    getPromedioRetraso() {
      return {
        label: "Retraso promedio",
        backgroundColor: "#4AFF78",
        data: this.groups.map((g) => g.timeDelayPromedio),
      };
    },
    getRetrasoMinimo() {
      return {
        label: "Retraso mínimo",
        backgroundColor: "#6556FF",
        data: this.groups.map((g) => g.timeDelayMin),
      };
    },
    getRetrasoMaximo() {
      return {
        label: "Retraso máximo",
        backgroundColor: "#34C7EB",
        data: this.groups.map((g) => g.timeDelayMax),
      };
    },
    getBandwidthPromedio() {
      return {
        label: "Ancho de banda promedio",
        backgroundColor: "#FF724F",
        data: this.groups.map((g) => g.bandwidthPromedio),
      };
    },
    getPromedioAnchoDeBanda() {
      this.groups.forEach((g) => {
        let suma = 0;
        for (const e of g.events) {
          suma += e.bandwidth;
        }
        g.bandwidthPromedio = suma / g.events.length;
      });
    },
    getRetrasos() {
      this.groups.forEach((g) => {
        let promedio = 0;
        let max = 0;
        let min = Infinity;
        for (const e of g.events) {
          if (e.timeDelay > max) {
            max = e.timeDelay;
          }
          if (e.timeDelay < min) {
            min = e.timeDelay;
          }
          promedio += e.timeDelay;
        }
        g.timeDelayPromedio = promedio / g.events.length / 1000; // retarno en seg
        g.timeDelayMax = max / 1000; // retarno en seg
        g.timeDelayMin = min / 1000; // retarno en seg
      });
    },
  },
};
</script>
