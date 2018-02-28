using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CsvAgg
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                Console.WriteLine("usage : ConsoleApp1.exe filename.csv");
            }

            var readFilePath = args[0];
            Stopwatch sw = new Stopwatch();

            sw.Start();
            Console.WriteLine("test start");

            // TODO: If want to only totally results (not depend by procedure),
            //   we can improvement performance with between combine ProcessReadAsync and OrderByDescending.
            var results = ProcessReadAsync(readFilePath).Result;

            Console.WriteLine(results.Count);

            var sorted = results
                .AsParallel()
                .WithDegreeOfParallelism(Environment.ProcessorCount)
                .OrderByDescending((x) => x.Value).Take(10);
            //var sorted = wordMap.OrderByDescending((x) => x.Value);

            sw.Stop();

            foreach (var rec in sorted)
            {
                Console.WriteLine(rec.Key + ":" + rec.Value.ToString());
            }

            var ts = sw.Elapsed;
            Console.WriteLine($"　{ts.Hours}時間 {ts.Minutes}分 {ts.Seconds}秒 {ts.Milliseconds}ミリ秒");
            Console.ReadKey(true);
        }

        private static async Task<Dictionary<string, int>> ProcessReadAsync(string path)
        {
            char[] separators = { ',' };

            var queue = new BlockingCollection<List<string>>(new ConcurrentBag<List<string>>());
            var readerTask = ReadFromCSVAsync(path, queue);

            // TODO: ParalellQuery.ToDictionay too slow,
            //   so we have to remove and replace better solution.

            var results = queue
                .GetConsumingEnumerable()
                .AsParallel()
                .WithDegreeOfParallelism(Environment.ProcessorCount)    // Force parallel count
                .SelectMany(lines => lines)
                .Select(line => line.Split(separators).Skip(1).First().Trim('"'))
                .GroupBy(column1 => column1)
                .ToDictionary(g => g.Key, g => g.Count());

            await readerTask;

            return results;
        }

        // Task is anchor for completion
        private static Task ReadFromCSVAsync(
            string path,
            BlockingCollection<List<string>> queue)
        {
            return Task.Run(() =>
            {
                try
                {
                    using (var fs = new FileStream(path,
                        FileMode.Open, FileAccess.Read, FileShare.Read,
                        4096, FileOptions.SequentialScan))
                    {
                        var tr = new StreamReader(fs);

                        var lines = new List<string>(1000);
                        while (!tr.EndOfStream)
                        {
                            var line = tr.ReadLine();
                            if (string.IsNullOrWhiteSpace(line))
                            {
                                continue;
                            }

                            lines.Add(line);
                            if (lines.Count >= 1000)
                            {
                                queue.Add(lines);
                                lines = new List<string>(1000);
                            }
                        }

                        if (lines.Count >= 1)
                        {
                            queue.Add(lines);
                        }
                    }
                }
                finally
                {
                    queue.CompleteAdding();
                }
            });
        }
    }
}
